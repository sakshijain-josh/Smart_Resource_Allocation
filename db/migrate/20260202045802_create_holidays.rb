class CreateHolidays < ActiveRecord::Migration[8.1]
  def change
    create_table :holidays, id: :uuid do |t|
      t.date :holiday_date
      t.string :name

      t.timestamps
    end
  end
end
