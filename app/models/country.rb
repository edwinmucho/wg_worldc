class Country < ActiveRecord::Base
    has_many :manager
    has_many :player
    has_many :tactic
end
