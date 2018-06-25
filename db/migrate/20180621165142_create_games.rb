class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|

      t.string :title
      t.string :home
      t.string :away
      t.string :game_date
      t.string :game_time
      t.string :game_state
      
      t.string  :result
      t.integer :r_hs
      t.integer :r_as
      t.timestamps null: false
    end
  end
end
