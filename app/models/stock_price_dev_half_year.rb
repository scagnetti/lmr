class StockPriceDevHalfYear < ActiveRecord::Base
  attr_accessible :succeeded, :error_msg
  has_many :score_cards
  has_many :momenta
end
