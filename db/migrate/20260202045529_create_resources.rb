class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources, id: :uuid do |t|
      t.string :name
      t.string :resource_type
      t.jsonb :properties
      t.boolean :is_active
      t.text :description
      t.string :location


      t.timestamps
    end

    add_index :resources, :properties, using: :gin
    add_index :resources, :name, unique: true

  end
end
