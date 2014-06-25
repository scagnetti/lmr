class EbitMargin < ActiveRecord::Base
  attr_accessible :last_year, :value, :succeeded
  has_many :score_cards
end
