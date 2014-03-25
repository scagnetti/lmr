# Contains all extracted data for a certain stock
class ScoreCard < ActiveRecord::Base
  attr_accessible :price, :currency, :share
  belongs_to :share
  belongs_to :return_on_equity
  belongs_to :reaction
  belongs_to :ebit_margin
  belongs_to :equity_ratio
  belongs_to :current_price_earnings_ratio
  belongs_to :average_price_earnings_ratio
  belongs_to :analysts_opinion
  belongs_to :profit_revision
  belongs_to :stock_price_dev_half_year
  belongs_to :stock_price_dev_one_year
  belongs_to :momentum
  belongs_to :reversal
  belongs_to :profit_growth

  # We are only interested in the latest score card of a share
  scope :latest_only, -> { joins("INNER JOIN (select max(id) max_id from score_cards group by share_id) l ON score_cards.id = l.max_id") }

  # Does NOT work because the value of the id cell doesn't have to come frome the same row as the value of max(create_at)
  # For details see: http://stackoverflow.com/questions/979034/mysql-shows-incorrect-rows-when-using-group-by
  # select id, max(created_at) from score_cards group by share_id;
  # And also this approach:
  # select * from score_cards group by share_id having max(created_at);
  
  # scope :created_filter, ->(d) { where("date(created_at) = ?", d) }
  scope :share_name, lambda { |value| joins(:share).where("shares.name like ?", value + "%") unless value.blank? }
end
