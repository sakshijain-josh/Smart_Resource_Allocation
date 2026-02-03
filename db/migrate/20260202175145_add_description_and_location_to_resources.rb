class AddDescriptionAndLocationToResources < ActiveRecord::Migration[8.1]
  def change
    add_column :resources, :description, :text
    add_column :resources, :location, :string
  end
end
