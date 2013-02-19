class EquityRatio < ActiveRecord::Base
  attr_accessible :last_year, :succeeded, :value
  has_many :score_cards
end
