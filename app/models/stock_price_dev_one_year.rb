class StockPriceDevOneYear < ActiveRecord::Base
  has_many :score_cards
  has_many :momenta
end
