class Reaction < ActiveRecord::Base
  attr_accessible :index_closing, :index_opening, :price_closing, :price_opening, :release_date
  has_many :score_cards
end
