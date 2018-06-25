class CreateForecasts < ActiveRecord::Migration
  def change
    create_table :forecasts do |t|
      
      t.references :user, foreign_key: true
      t.references :game, foreign_key: true      
      t.string :f_home
      t.string :f_away
      t.string :f_guess #"H : 홈승리/ A : 어웨이승리 / D : 무승부 "
      t.integer :f_hs
      t.integer :f_as
      
      t.boolean :ispredict
      t.integer :get_point, default: 0
      t.integer :get_alpha, default: 0
      t.integer :corr_count, default: 0
      
      t.boolean :isapply

      t.timestamps null: false
    end
  end
end
