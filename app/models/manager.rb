class Manager < ActiveRecord::Base
    belongs_to :country
    has_many :tactic
end
