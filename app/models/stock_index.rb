class StockIndex < ActiveRecord::Base
  has_many :shares
  attr_accessible :isin, :name
  validates :isin, :uniqueness => true
  validates :isin, :length => { :is => 12 , :message => "muss aus 12 Zeichen bestehen"}
  validates :name, :length => { :minimum => 2 , :message => "muss mindesten aus 2 Zeichen bestehen"}
end
