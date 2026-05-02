class CreateRegistrations < ActiveRecord::Migration[7.2]
  def change
    create_table :registrations do |t|
      t.string :name_th
      t.string :name_en
      t.string :category
      t.string :district
      t.string :province
      t.string :phone
      t.string :email
      t.string :song
      t.integer :duration
      t.string :competition_type
      t.integer :price
      t.integer :vat
      t.integer :total
      t.integer :status, limit: 3

      t.timestamps
    end
  end
end
