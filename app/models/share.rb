class Share < ActiveRecord::Base

  belongs_to :stock_index
  has_many :score_cards
  
  validates :isin, :uniqueness => true
  validates :isin, :length => { :is => 12 , :message => "has to match exactly 12 characters"}
  validates :name, :length => { :minimum => 2 , :message => "must consist of at least 2 characters"}
  
  default_scope {order('name ASC')}
  scope :share_name, lambda { |value| where("name like ? OR isin like ?", value + "%", value) unless value.blank? }
  scope :stock_index, lambda { |value| where("stock_index_id = ?", value) unless value.blank?}
  
  def to_s
    s = "#{isin} #{name}, Financial: #{financial}, Size: #{size}, Currency: #{currency}, Stock Exchange: #{stock_exchange}, Stock Index: #{stock_index.name}"
    return s
  end
end
