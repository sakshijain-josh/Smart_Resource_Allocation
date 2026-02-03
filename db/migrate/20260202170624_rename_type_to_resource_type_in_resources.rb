class RenameTypeToResourceTypeInResources < ActiveRecord::Migration[8.1]
  def change
    rename_column :resources, :type, :resource_type
  end
end
