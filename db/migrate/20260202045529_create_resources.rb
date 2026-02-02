class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources, id: :uuid do |t|
      t.string :name
      t.string :type
      t.jsonb :properties
      t.boolean :is_active

      t.timestamps
    end

    add_index :resources, :properties, using: :gin

  end
end
