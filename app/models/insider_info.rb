require 'engine/util.rb'
class InsiderInfo < ActiveRecord::Base
  has_many :insider_deals, autosave: true
  belongs_to :score_card

  def buy_transactions
    c = 0
    insider_deals.each do |d|
      exp = Util.information_expired_as_date(d.occurred, 30)
      if d.buy? && !exp
        c = c + 1
      end
    end
    return c
  end

  def sell_transactions
    c = 0
    insider_deals.each do |d|
      exp = Util.information_expired_as_date(d.occurred, 30)
      if d.sell? && !exp
        c = c + 1
      end
    end
    return c
  end

  def insider_deals?
    return buy_transactions + sell_transactions > 0 ? true : false
  end

  def total_buy_volume()
    total = 0
    insider_deals.each do |deal|

      exp = Util.information_expired_as_date(deal.occurred, 30)

      if deal.buy? && !exp
        total = total + deal.quantity * deal.price
      end
    end
    return total
  end

  def total_sell_volume()
    total = 0
    insider_deals.each do |deal|

      exp = Util.information_expired_as_date(deal.occurred, 30)

      if deal.sell? && !exp
        total = total + deal.quantity * deal.price
      end
    end
    return total
  end

  def balance()
    return total_buy_volume() - total_sell_volume()
  end
end
