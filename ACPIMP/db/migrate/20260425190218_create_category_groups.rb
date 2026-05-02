class CreateCategoryGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :category_groups do |t|
      t.string :name_th
      t.string :name_en
      t.string :code
      t.timestamps
    end
  end
end
