class StockPriceDevHalfYear < ActiveRecord::Base
  attr_accessible :succeeded, :error_msg, :today, :half_year_ago, :one_year_ago, :momentum
  has_many :score_cards
  has_many :momenta
end
