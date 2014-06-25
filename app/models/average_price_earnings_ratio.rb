class AveragePriceEarningsRatio < ActiveRecord::Base
  attr_accessible :succeeded, :three_years_ago ,:two_years_ago ,:last_year ,:this_year ,:next_year, :average, :value_three_years_ago, :value_two_years_ago, :value_last_year, :value_this_year, :value_next_year
  has_many :score_cards
end
