class Reaction < ActiveRecord::Base
  attr_accessible :index_after, :index_before, :price_after, :price_before, :release_date, :before, :after
  has_many :score_cards
  
  validates :index_after, :index_before, :price_after, :price_before, :share_perf, :index_perf, presence: true
  validates :index_after, :index_before, :price_after, :price_before, :share_perf, :index_perf, numericality: true
end
