module InsiderDealsHelper
  def as_string(trade_type)
    if Transaction::BUY == trade_type
      return 'Buy'
    elsif Transaction::SELL == trade_type
      return 'Sell'
    else
      return 'Unknown'
    end
  end
end
