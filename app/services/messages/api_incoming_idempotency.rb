module Messages::ApiIncomingIdempotency
  SOURCE_PREFIX = 'WAID:'.freeze
  LOCK_SQL = 'SELECT pg_advisory_xact_lock(hashtextextended($1, 0))::text'.freeze

  def perform
    return super unless idempotent_api_incoming?

    Message.transaction(requires_new: true) do
      acquire_api_incoming_lock!
      @message = existing_api_incoming_message || super
    end
  end

  private

  def idempotent_api_incoming?
    @message_type == 'incoming' &&
      @conversation.inbox.channel_type == 'Channel::Api' &&
      @params[:source_id].to_s.start_with?(SOURCE_PREFIX)
  end

  def acquire_api_incoming_lock!
    bind = ActiveRecord::Relation::QueryAttribute.new(
      'api_incoming_lock_key',
      [@account.id, @conversation.inbox_id, @params[:source_id]].join(':'),
      ActiveRecord::Type::String.new
    )
    Message.connection.select_value(LOCK_SQL, 'API incoming message idempotency lock', [bind])
  end

  def existing_api_incoming_message
    Message.unscoped.find_by(
      account_id: @account.id,
      inbox_id: @conversation.inbox_id,
      message_type: Message.message_types[:incoming],
      source_id: @params[:source_id]
    )
  end
end
