class ProfitRevision < ActiveRecord::Base
  attr_accessible :succeeded
  has_many :score_cards
end
