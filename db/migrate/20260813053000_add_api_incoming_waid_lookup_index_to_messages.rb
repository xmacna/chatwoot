class AddApiIncomingWaidLookupIndexToMessages < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :messages,
              [:account_id, :inbox_id, :source_id],
              name: 'index_messages_on_api_incoming_waid',
              where: "message_type = 0 AND source_id LIKE 'WAID:%'",
              algorithm: :concurrently,
              if_not_exists: true
  end
end
