class ProfitGrowth < ActiveRecord::Base
  attr_accessible :error_msg, :succeeded, :value_last_year, :value_this_year
  has_many :score_cards
end
