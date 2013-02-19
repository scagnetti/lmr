# Capable of rating each figure with -1,0 or +1
class RatingUnit
  
  public
  
  # Assess the return on equity value
  def RatingUnit.rate_roe(return_on_equity)
    case 
    when return_on_equity.value > 20
      score = 1
    when return_on_equity.value < 10
      score = -1
    else
      score = 0
    end
    return_on_equity.score = score
  end
  
  # Assess the ebit margin value
  def RatingUnit.rate_ebit_margin(ebit_margin)
    case 
    when ebit_margin.value > 12
      score = 1
    when ebit_margin.value < 6
      score = -1
    else
      score = 0
    end
    ebit_margin.score = score
  end
  
  # Assess the equity ratio value
  def RatingUnit.rate_equity_ratio(equity_ratio)
    case 
    when equity_ratio.value > 25
      score = 1
    when equity_ratio.value < 15
      score = -1
    else
      score = 0
    end
    equity_ratio.score = score
  end
  
  # Assess the average price earnings ratio value
  # * per the average price earnings ratio
  def RatingUnit.rate_average_price_earnings_ratio(per)
    sum = per.value_three_years_ago + per.value_two_years_ago + per.value_last_year + per.value_this_year + per.value_next_year
    avg = sum / 5
    case 
    when avg < 12
      score = 1
    when avg > 16
      score = -1
    else
      score = 0
    end
    per.average = avg
    per.score = score
  end
  
  # Assess the current price earnings ratio value
  # * per the current price earnings ratio
  def RatingUnit.rate_current_price_earnings_ratio(per)
    case 
    when per.value < 12
      score = 1
    when per.value > 16
      score = -1
    else
      score = 0
    end
    per.score = score
  end
  
  # TODO: Assess the analysts opinions
  # For large caps:
  # * if the majority says sell we rate +1
  # * if the majority says hold we rate 0
  # * if the majority says buy we rate -1  
  def RatingUnit.rate_analysts_opinion(analysts_opinion)
    all = analysts_opinion.buy + analysts_opinion.hold + analysts_opinion.sell
    LOG.debug("RatingUnit: Total opinions: #{all}")
    buy = analysts_opinion.buy.to_f / all
    LOG.debug("RatingUnit: buy in percent: #{buy}")
    hold = analysts_opinion.hold.to_f / all
    LOG.debug("RatingUnit: hold in percent: #{hold}")
    sell = analysts_opinion.sell.to_f / all
    LOG.debug("RatingUnit: sell in percent: #{sell}")
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
  
  # Assess the reaction on the release of quarterly figures
  def RatingUnit.rate_reaction(reaction)
    stock_performance = Util.perf(reaction.price_closing, reaction.price_opening)
    LOG.debug("RatingUnit - stock performance: #{stock_performance}")
    index_performance = Util.perf(reaction.index_closing, reaction.index_opening)
    LOG.debug("RatingUnit - index performance: #{index_performance}")
    diff = stock_performance - index_performance
    LOG.debug("RatingUnit - performance diff: #{diff}")
    case 
    when diff > 1
      score = 1
    when diff < -1
      score = -1
    else
      score = 0
    end
    reaction.score = score
  end
  
  # Assess the profit revision value
  def RatingUnit.rate_profit_revision(profit_revision)
    u = profit_revision.up
    e = profit_revision.equal
    d = profit_revision.down
    case
    when u > e && u > d
      score = 1
    when e > u && e > d
      score = 0
    when d > u && d > e
      score = -1
    when u == e && e == d
      score = 0
    when u == e || u > d
      score = 0
    when u == d
      score = 0
    else
      score = -1
    end
    profit_revision.score = score
  end
  
  # Assess the half year stock price development
  def RatingUnit.rate_stock_price_dev_half_year(stock_price_dev_half_year)
    now = stock_price_dev_half_year.compare
    past = stock_price_dev_half_year.value
    perf = Util.perf(now, past)
    case
    when perf > 5
      score = 1
    when perf < -5
      score = -1
    else
      score = 0
    end
    stock_price_dev_half_year.perf = perf
    stock_price_dev_half_year.score = score
  end
  
  # Assess the one year stock price development
  def RatingUnit.rate_stock_price_dev_one_year(stock_price_dev_one_year)
    now = stock_price_dev_one_year.compare
    past = stock_price_dev_one_year.value
    perf = Util.perf(now, past)
    case
    when perf > 5
      score = 1
    when perf < -5
      score = -1
    else
      score = 0
    end
    stock_price_dev_one_year.perf = perf
    stock_price_dev_one_year.score = score
  end
  
    def RatingUnit.rate_stock_price_dev(past, now)
    perf = Util.perf(now, past)
    LOG.debug("RatingUnit - #{past} half year ago -> today #{now} - half year performance: #{perf}%")
    case
    when perf > 5
      return 1
    when perf < -5
      return -1
    else
      return 0
    end
  end
  
  # Assess the stock price momentum
  def RatingUnit.rate_stock_price_momentum(momentum)
    half_year = momentum.stock_price_dev_half_year.score
    one_year = momentum.stock_price_dev_one_year.score
    case
    when half_year == 1 && (one_year == -1 || one_year == 0)
      score = 1
    when half_year == -1 && (one_year == 1 || one_year == 0)
      score = -1
    else
      score = 0
    end
    momentum.score = score
  end
  
  # Assess the three month reversal
  def RatingUnit.rate_reversal(reversal)
    # Stock performance
    reversal.value_perf_three_months_ago = Util.perf(reversal.value_three_months_ago, reversal.value_four_months_ago) 
    reversal.value_perf_two_months_ago = Util.perf(reversal.value_two_months_ago, reversal.value_three_months_ago)
    reversal.value_perf_one_month_ago = Util.perf(reversal.value_one_month_ago, reversal.value_three_months_ago)
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
  
  # Assess the profit growth
  def RatingUnit.rate_profit_growth(profit_growth)
    profit_growth.perf = Util.perf(profit_growth.value_next_year, profit_growth.value_this_year)
    case
    when profit_growth.perf > 5
      score = 1
    when profit_growth.perf < -5
      score = -1
    else
      score = 0
    end
    profit_growth.score = score
  end
end
