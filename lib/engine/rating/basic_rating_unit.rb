# Encapsulate the rating functions which are the same,
# for small, mid, large and financial companies.
class BasicRatingUnit
  
  # Assess the return on equity value
  def rate_roe(return_on_equity)
    case 
    when return_on_equity.value > 20
      score = 1
    when return_on_equity.value < 10
      score = -1
    else
      score = 0
    end
    return_on_equity.score = score
    return score
  end
  
  # Assess the ebit margin value
  def rate_ebit_margin(ebit_margin)
    # Financial stockes get zero points
    raise RatingError, "Could not rate ebit margin", caller
  end
  
  # Assess the equity ratio value (Eigenkapitalquote)
  def rate_equity_ratio(equity_ratio)
    # Financial stockes need less equity
    raise RatingError, "Could not rate equity ratio", caller
  end
  
  # Assess the average price earnings ratio value
  # * per the average price earnings ratio
  def rate_average_price_earnings_ratio(per)
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
    return score
  end
  
  # Assess the current price earnings ratio value
  # * per the current price earnings ratio
  def rate_current_price_earnings_ratio(per)
    case 
    when per.value < 12
      score = 1
    when per.value > 16
      score = -1
    else
      score = 0
    end
    per.score = score
    return score
  end
  
  # Assess the analysts opinions
  def rate_analysts_opinion(analysts_opinion)
    # Small caps are rated positive if only a few (less than five) analysts watch the stock
    raise RatingError, "Could not rate analysts opinions", caller
  end
  
  # Assess the reaction on the release of quarterly figures
  def rate_reaction(reaction)
    stock_performance = Util.perf(reaction.price_after, reaction.price_before)
    LOG.debug("#{self.class}: stock performance: #{stock_performance}")
    reaction.share_perf = stock_performance
    index_performance = Util.perf(reaction.index_after, reaction.index_before)
    LOG.debug("#{self.class}: index performance: #{index_performance}")
    reaction.index_perf = index_performance
    diff = stock_performance - index_performance
    LOG.debug("#{self.class}: performance diff: #{diff}")
    case 
    when diff > 1
      score = 1
    when diff < -1
      score = -1
    else
      score = 0
    end
    reaction.score = score
    return score
  end
  
  # Assess the profit revision value
  def rate_profit_revision(profit_revision)
    ## Deprecated see OnVistaExtractor.extract_profit_revision(...)
    # u = profit_revision.up
    # e = profit_revision.equal
    # d = profit_revision.down
    # case
    # when u > e && u > d
      # score = 1
    # when e > u && e > d
      # score = 0
    # when d > u && d > e
      # score = -1
    # when u == e && e == d
      # score = 0
    # when u == e || u > d
      # score = 0
    # when u == d
      # score = 0
    # else
      # score = -1
    # end
    # profit_revision.score = score
    
    case
    when profit_revision.up == 1
      score = 1
    when profit_revision.equal == 1
      score = 0
    when profit_revision.down == 1
      score = -1
    else
      score = -1
    end
    profit_revision.score = score
    return score
  end
  
  # Assess the half year stock price development
  def rate_stock_price_dev_half_year(stock_price_dev_half_year)
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
    return score
  end
  
  # Assess the one year stock price development
  def rate_stock_price_dev_one_year(stock_price_dev_one_year)
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
    return score
  end
  
  # Assess the stock price momentum
  def rate_stock_price_momentum(momentum)
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
    return score
  end
  
  # Assess the three month reversal
  def rate_reversal(reversal)
    raise RatingError, "Could not rate three months reversal margin", caller
  end
  
  # Assess the profit growth
  def rate_profit_growth(profit_growth)
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
    return score
  end
end
