class Tactic < ActiveRecord::Base
    belongs_to :country
    belongs_to :manager
end
