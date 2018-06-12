class CreateManagers < ActiveRecord::Migration
  def change
    create_table :managers do |t|
      t.references :country, foreign_key: true
      t.string :name
      t.string :pic_url
      
      t.timestamps null: false
    end
  end
end
