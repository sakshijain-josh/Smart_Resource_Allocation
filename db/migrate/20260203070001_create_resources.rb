class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.string :name
      t.string :resource_type
      t.text :description
      t.string :location
      t.boolean :is_active
      t.jsonb :properties

      t.timestamps
    end

    add_index :resources, :properties, using: :gin
  end
end
