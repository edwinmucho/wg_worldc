class User < ActiveRecord::Base
    belongs_to :country
    has_many :forecast
    has_many :games, through: :forecast
end
