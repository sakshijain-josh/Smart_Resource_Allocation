class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :booking, type: :uuid, foreign_key: true
      t.references :resource, type: :uuid, foreign_key: true
      t.uuid :performed_by
      t.string :action, null: false
      t.integer :old_status
      t.integer :new_status
      t.text :message

      t.timestamps
    end

    add_foreign_key :audit_logs, :users, column: :performed_by

  end
end
