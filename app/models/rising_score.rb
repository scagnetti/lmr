class RisingScore < ActiveRecord::Base
  attr_accessible :days, :isin
  belongs_to :share
end
