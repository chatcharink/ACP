class CreateScoreCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :score_categories do |t|
      t.string :name
      t.integer :max_score

      t.timestamps
    end
  end
end
