class CreateGalleries < ActiveRecord::Migration[7.2]
  def change
    create_table :galleries do |t|
      t.string :image
      t.integer :position
      t.timestamps
    end
  end
end
