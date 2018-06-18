class CreateBuglists < ActiveRecord::Migration
  def change
    create_table :buglists do |t|
      t.string :user_key
      t.string :err_msg
      t.string :usr_msg
      t.string :mstep
      t.string :fstep

      t.timestamps null: false
    end
  end
end
