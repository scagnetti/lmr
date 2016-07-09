class Momentum < ActiveRecord::Base
  has_many :score_cards
  belongs_to :stock_price_dev_half_year
  belongs_to :stock_price_dev_one_year
end
