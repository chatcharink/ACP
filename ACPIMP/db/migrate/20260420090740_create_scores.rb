class CreateScores < ActiveRecord::Migration[7.2]
  def change
    create_table :scores do |t|
      t.references :registration, type: :bigint, limit: 20, null: false, foreign_key: true
      t.references :user, type: :bigint, limit: 20, null: false, foreign_key: true
      t.references :score_category, null: false, foreign_key: true
      t.integer :value
      t.text :comment

      t.timestamps
    end
  end
end
