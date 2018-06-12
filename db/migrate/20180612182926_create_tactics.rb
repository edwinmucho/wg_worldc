class CreateTactics < ActiveRecord::Migration
  def change
    create_table :tactics do |t|
      t.references :country, foreign_key: true
      t.string :name
      t.string :height
      t.string :weight
      t.string :age
      t.string :position
      t.string :back_num
      t.string :team
      t.string :pic_url

      t.integer :goal
      t.integer :assist
      t.integer :y_card
      t.integer :r_card
      
      t.timestamps null: false
    end
  end
end
