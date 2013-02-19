class AnalystsOpinion < ActiveRecord::Base
  attr_accessible :buy, :hold, :sell, :succeeded
  has_many :score_cards
end
