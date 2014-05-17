class InsiderDeal < ActiveRecord::Base
  attr_accessible :link, :occurred, :person, :price, :quantity, :trade_type, :share
  belongs_to :share
  default_scope order('occurred DESC')
  scope :restrict, lambda { |value| where("insider_deals.share_id = ?", value) unless value.blank? }
end
