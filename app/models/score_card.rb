# Contains all extracted data for a certain stock
class ScoreCard < ActiveRecord::Base
  attr_accessible :price, :currency, :share
  belongs_to :share
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

  #scope :created_filter, ->(d) { where("date(created_at) = ?", d) }
  default_scope order('created_at DESC')
  scope :creation, lambda { |value| where("date(score_cards.created_at) = ?", value) unless value.blank? }
  scope :share_name, lambda { |value| joins(:share).where("shares.name like ?", value + "%") unless value.blank? }
end
