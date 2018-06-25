class Game < ActiveRecord::Base
    has_many :forecast
    has_many :users, through: :forecast
end
