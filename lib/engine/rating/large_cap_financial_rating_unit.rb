require 'engine/rating/basic_rating_unit.rb'
# Use a large cap rating with adoption for financial stocks
class LargeCapFinancialRatingUnit < LargeCapRatingUnit
  
  public
  
  # Assess the ebit margin value
  def rate_ebit_margin(ebit_margin)
    ebit_margin.score = 0
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
  end
  
  # Assess the analysts opinions
  # For large caps:
  # * if the majority says sell we rate +1
  # * if the majority says hold we rate 0
  # * if the majority says buy we rate -1  
  def rate_analysts_opinion(analysts_opinion)
    all = analysts_opinion.buy + analysts_opinion.hold + analysts_opinion.sell
    LOG.debug("#{self.class}: Total opinions: #{all}")
    buy = analysts_opinion.buy.to_f / all
    LOG.debug("#{self.class}: buy in percent: #{buy}")
    hold = analysts_opinion.hold.to_f / all
    LOG.debug("#{self.class}: hold in percent: #{hold}")
    sell = analysts_opinion.sell.to_f / all
    LOG.debug("#{self.class}: sell in percent: #{sell}")
    case
    when buy > hold && buy > sell
      score = -1
    when hold > buy && hold > sell
      score = 0
    when sell > buy && sell > hold
      score = 1
    else
      score = -1
    end
    analysts_opinion.score = score
  end
  
  # Assess the three month reversal
  def rate_reversal(reversal)
    # Stock performance
    reversal.value_perf_three_months_ago = Util.perf(reversal.value_three_months_ago, reversal.value_four_months_ago) 
    reversal.value_perf_two_months_ago = Util.perf(reversal.value_two_months_ago, reversal.value_three_months_ago)
    reversal.value_perf_one_month_ago = Util.perf(reversal.value_one_month_ago, reversal.value_two_months_ago)
    # Index performance
    reversal.index_perf_three_months_ago = Util.perf(reversal.index_three_months_ago, reversal.index_four_months_ago)
    reversal.index_perf_two_months_ago = Util.perf(reversal.index_two_months_ago, reversal.index_three_months_ago)
    reversal.index_perf_one_month_ago = Util.perf(reversal.index_one_month_ago, reversal.index_two_months_ago)
    case
    when reversal.value_perf_three_months_ago < reversal.index_perf_three_months_ago && reversal.value_perf_two_months_ago < reversal.index_perf_two_months_ago && reversal.value_perf_one_month_ago < reversal.index_perf_one_month_ago
      score = 1 
    when reversal.value_perf_three_months_ago > reversal.index_perf_three_months_ago && reversal.value_perf_two_months_ago > reversal.index_perf_two_months_ago && reversal.value_perf_one_month_ago > reversal.index_perf_one_month_ago
      score = -1
    else
      score = 0
    end
    reversal.score = score
  end

end
