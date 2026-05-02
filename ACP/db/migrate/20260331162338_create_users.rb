class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :firstname 
      t.string :lastname 
      t.string :telephone
      t.string :email
      t.integer :status, limit: 3
      t.integer :role, limit: 3
      t.timestamps
    end
  end
end
