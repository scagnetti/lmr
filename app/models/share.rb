class Share < ActiveRecord::Base
  attr_accessible :financial, :isin, :name, :size, :currency, :stock_exchange
  belongs_to :stock_index
  has_many :insider_deals, :limit => 20
  has_many :score_cards
  validates :isin, :uniqueness => true
  validates :isin, :length => { :is => 12 , :message => "has to match exactly 12 characters"}
  validates :name, :length => { :minimum => 2 , :message => "must consist of at least 2 characters"}
  
  default_scope order('name ASC')
  scope :share_name, lambda { |value| where("name like ?", value + "%") unless value.blank? }
  
  def to_s
    s = "#{name} (#{isin}), Stock Exchange: #{stock_exchange}, Stock Index: #{stock_index.name}"
    return s
  end
end
