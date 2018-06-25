class AddNickPointToUser < ActiveRecord::Migration
  def change
    add_column :users, :nick, :string
    add_column :users, :point, :integer
  end
end
