class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_key
      t.integer :chat_room
      t.references :country, foreign_key: true

      t.timestamps null: false
    end
  end
end
