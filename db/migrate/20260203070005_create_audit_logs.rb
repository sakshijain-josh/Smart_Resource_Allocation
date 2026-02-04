class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.string :action, null: false
      t.bigint :performed_by
      t.references :booking, foreign_key: true
      t.references :resource, foreign_key: true
      t.integer :old_status
      t.integer :new_status
      t.text :message

      t.timestamps
    end

    add_foreign_key :audit_logs, :users, column: :performed_by
  end
end
