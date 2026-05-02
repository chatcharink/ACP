class AddCodeToRegistrations < ActiveRecord::Migration[7.2]
  def change
    add_column :registrations, :code, :string
  end
end
