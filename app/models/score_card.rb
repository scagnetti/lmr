# Contains all extracted data for a certain stock
class ScoreCard < ActiveRecord::Base
  attr_accessible :financial, :isin, :name, :price, :stock_index
  belongs_to :stock_index
  belongs_to :return_on_equity
  belongs_to :reaction
  belongs_to :ebit_margin
  belongs_to :equity_ratio
  belongs_to :current_price_earnings_ratio
  belongs_to :average_price_earnings_ratio
  belongs_to :analysts_opinion
  belongs_to :profit_revision
  belongs_to :stock_price_dev_half_year
  belongs_to :stock_price_dev_one_year
  belongs_to :momentum
  belongs_to :reversal
  belongs_to :profit_growth
end
