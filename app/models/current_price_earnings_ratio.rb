class CurrentPriceEarningsRatio < ActiveRecord::Base
  attr_accessible :succeeded, :this_year, :value
  has_many :score_cards
end
