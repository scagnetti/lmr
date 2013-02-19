class Momentum < ActiveRecord::Base
  attr_accessible :error_msg, :score, :succeeded
  has_many :score_cards
  belongs_to :stock_price_dev_half_year
  belongs_to :stock_price_dev_one_year
end
