class AveragePriceEarningsRatio < ActiveRecord::Base
  attr_accessible :succeeded, :this_year, :this_year_value
  has_many :score_cards
end
