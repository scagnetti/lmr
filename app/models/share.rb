class Share < ActiveRecord::Base
  attr_accessible :financial, :isin, :name, :size
  belongs_to :stock_index
  has_many :insider_deals
  has_many :score_cards
  validates :isin, :uniqueness => true
  validates :isin, :length => { :is => 12 , :message => "muss aus 12 Zeichen bestehen"}
  validates :name, :length => { :minimum => 2 , :message => "muss mindesten aus 2 Zeichen bestehen"}
end