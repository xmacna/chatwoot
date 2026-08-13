require 'rails_helper'

describe Messages::ApiIncomingIdempotency do
  self.use_transactional_tests = false

  it 'serializes 20 exact Evolution deliveries into one incoming message' do
    account = create(:account)
    user = create(:user, account: account)
    channel = create(:channel_api, account: account)
    conversation = create(:conversation, inbox: channel.inbox, account: account)
    source_id = "WAID:CONCURRENCY:#{SecureRandom.hex(12)}"
    barrier = Concurrent::CyclicBarrier.new(20)
    message_ids = Concurrent::Array.new
    errors = Concurrent::Array.new

    threads = Array.new(20) do
      Thread.new do
        barrier.wait
        ActiveRecord::Base.connection_pool.with_connection do
          params = ActionController::Parameters.new(
            content: 'same inbound content',
            message_type: 'incoming',
            source_id: source_id
          )
          message_ids << Messages::MessageBuilder.new(user, conversation, params).perform.id
        rescue StandardError => e
          errors << e
        end
      end
    end
    threads.each(&:join)

    expect(errors).to be_empty
    expect(message_ids.uniq.size).to eq(1)
    expect(Message.where(account_id: account.id, inbox_id: channel.inbox.id, source_id: source_id).count).to eq(1)
  ensure
    account&.destroy!
  end
end
