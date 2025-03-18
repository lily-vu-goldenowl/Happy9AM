class CreateMessageLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :message_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :status, null: false
      t.datetime :sent_at
      t.text :error_message

      t.timestamps
    end

    add_index :message_logs, [:user_id, :event_type, 'Date(sent_at)']
  end
end
