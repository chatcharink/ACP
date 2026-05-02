class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name_th
      t.string :name_en
      t.string :code
      t.references :category_group, null: false, foreign_key: true
      t.boolean :active
      t.timestamps
    end
  end
end
