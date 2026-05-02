class CreateSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :settings do |t|
      t.text :terms_th
      t.text :terms_en

      t.text :rules_online_th
      t.text :rules_online_en

      t.text :rules_onsite_th
      t.text :rules_onsite_en
      t.timestamps
    end
  end
end
