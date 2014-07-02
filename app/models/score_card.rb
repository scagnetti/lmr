# Contains all extracted data for a certain stock
class ScoreCard < ActiveRecord::Base
  attr_accessible :price, :currency, :share
  belongs_to :share
  belongs_to :return_on_equity, autosave: true
  belongs_to :reaction, autosave: true
  belongs_to :ebit_margin, autosave: true
  belongs_to :equity_ratio, autosave: true
  belongs_to :current_price_earnings_ratio, autosave: true
  belongs_to :average_price_earnings_ratio, autosave: true
  belongs_to :analysts_opinion, autosave: true
  belongs_to :profit_revision, autosave: true
  belongs_to :stock_price_dev_half_year, autosave: true
  belongs_to :stock_price_dev_one_year, autosave: true
  belongs_to :momentum, autosave: true
  belongs_to :reversal, autosave: true
  belongs_to :profit_growth, autosave: true

  after_initialize do |score_card|
    if new_record?
      score_card.return_on_equity = ReturnOnEquity.new
      score_card.ebit_margin = EbitMargin.new
      score_card.equity_ratio = EquityRatio.new
      score_card.current_price_earnings_ratio = CurrentPriceEarningsRatio.new
      score_card.average_price_earnings_ratio = AveragePriceEarningsRatio.new
      score_card.analysts_opinion = AnalystsOpinion.new
      score_card.reaction = Reaction.new
      score_card.profit_revision = ProfitRevision.new
      score_card.stock_price_dev_half_year = StockPriceDevHalfYear.new
      score_card.stock_price_dev_one_year = StockPriceDevOneYear.new
      score_card.momentum = Momentum.new
      score_card.reversal = Reversal.new
      score_card.profit_growth = ProfitGrowth.new
    end
  end

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
