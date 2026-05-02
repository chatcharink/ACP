class AddSongStatusToRegistrations < ActiveRecord::Migration[7.2]
  def change
    add_column :registrations, :song_status, :integer
  end
end
