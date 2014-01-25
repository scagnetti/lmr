class StockIndex < ActiveRecord::Base
  has_many :shares
  attr_accessible :isin, :name
  validates :isin, :uniqueness => true
  validates :isin, :length => { :is => 12 , :message => "has to match exactly 12 characters"}
  validates :name, :length => { :minimum => 2 , :message => "must consist of at least 2 characters"}
  
  default_scope order('name ASC')
end
