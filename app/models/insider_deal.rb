class InsiderDeal < ActiveRecord::Base
  attr_accessible :link, :occurred, :person, :price, :quantity, :trade_type, :share
  belongs_to :share
end
