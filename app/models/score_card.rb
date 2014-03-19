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
  # select * from score_cards group by share_id having max(created_at);
  scope :latest_only , group("share_id").having("max(score_cards.created_at)").order("total_score DESC")
  #SELECT id, max(created_at) from score_cards group by share_id
  #SELECT * from score_cards where created_at = (select max(created_at) from score_cards as sub where sub.share_id = score_cards.share_id)
  #select * from score_cards where id in (SELECT id from score_cards group by share_id order by score_cards.created_at DESC) order by total_score DESC
  #Doesn't work on MYSQL
  #scope :latest_only, where("score_cards.id in (SELECT id from score_cards group by share_id order by score_cards.created_at DESC)").order("total_score DESC")
  #scope :latest_only , where("created_at = (select max(created_at) from score_cards as sub where sub.share_id = score_cards.share_id)").order("total_score DESC")

  # scope :created_filter, ->(d) { where("date(created_at) = ?", d) }
  
  # Can't be used because of latest_only scope
  # default_scope order('created_at DESC')
  
  # Dynamic finders
  scope :creation, lambda { |value| where("date(score_cards.created_at) = ?", value) unless value.blank? }
  scope :share_name, lambda { |value| joins(:share).where("shares.name like ?", value + "%") unless value.blank? }
end
