require 'engine/rating/basic_rating_unit.rb'
# Use a small cap rating with adoption for financial stocks
class SmallCapFinancialRatingUnit < SmallCapRatingUnit
  
  public
  
  # Assess the ebit margin value
  def rate_ebit_margin(ebit_margin)
    ebit_margin.score = 0
    return 0
  end
  
  # Assess the equity ratio value
  def rate_equity_ratio(equity_ratio)
    case 
    when equity_ratio.value > 10
      score = 1
    when equity_ratio.value < 5
      score = -1
    else
      score = 0
    end
    equity_ratio.score = score
    return score
  end
  
  # Assess the analysts opinions. If there are less than five analysts
  # we rate a buy flag as positive and sell flag negative.
  # For large caps:
  # * if the majority says sell we rate +1
  # * if the majority says hold we rate 0
  # * if the majority says buy we rate -1  
  def rate_analysts_opinion(analysts_opinion)
    all = analysts_opinion.buy + analysts_opinion.hold + analysts_opinion.sell
    Rails.logger.debug("#{self.class}: Total opinions: #{all}")
    buy = analysts_opinion.buy.to_f / all
    Rails.logger.debug("#{self.class}: buy in percent: #{buy}")
    hold = analysts_opinion.hold.to_f / all
    Rails.logger.debug("#{self.class}: hold in percent: #{hold}")
    sell = analysts_opinion.sell.to_f / all
    Rails.logger.debug("#{self.class}: sell in percent: #{sell}")
    case
    when buy > hold && buy > sell
      if all > 5
        score = -1
      else
        Rails.logger.debug("#{self.class}: switching rule because less than five analysts are watching")
        score = 1
      end
    when hold > buy && hold > sell
      score = 0
    when sell > buy && sell > hold
      if all > 5
        score = 1
      else
        Rails.logger.debug("#{self.class}: switching rule because less than five analysts are watching")
        score = -1
      end
    else
      score = -1
    end
    analysts_opinion.score = score
    return score
  end
  
  # Assess the three month reversal
  def rate_reversal(reversal)
    reversal.score = 0
    return 0
  end
  
  # Assess insider deals
  def rate_insider_deals(insider_info)
    unless insider_info.insider_deals?
      return 0
    end

    absolut = insider_info.total_buy_volume() - insider_info.total_sell_volume()
    if absolut > 80000
      return 1
    elsif absolut < 0
      return -1
    else
      return 0
    end
  end

  # Assess insider deals
  def rate_insider_deals(insider_info)
    score = 0

    if insider_info.insider_deals?

      absolut = insider_info.balance()

      if absolut > 80000
        score = 1
      elsif absolut < 0
        score = -1
      end

    end

    insider_info.score = score
    
    return score
  end
end
