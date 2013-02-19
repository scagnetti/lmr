class StockPriceDevOneYear < ActiveRecord::Base
  attr_accessible :error_msg, :score, :succeeded
  has_many :score_cards
  has_many :momenta
end
