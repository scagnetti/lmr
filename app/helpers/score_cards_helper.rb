module ScoreCardsHelper
  
  # Calculates the CSS class to highlight the score in the right color
  # TODO Update for Small Caps and financial values
  def highlight(score)
    if score >= 4
      return "label label-success"
    else
      return "label label-danger"
    end
  end
  
  def get_options_for_select
    options = StockIndex.all.collect {|si| [ si.name, si.id ] }
    options.unshift(['All', -1])
    return options_for_select(options)
  end

  def resolve_info_for_equity_ratio(share)
    if share.financial
      return "> 10% | 10% - 5% | < 5%"
    else
      return "> 25% | 25% - 15% | < 15%"
    end
  end

  def resolve_info_for_ebit_margin(share)
    if share.financial
      return "0"
    else
      return "> 12% | 12% - 6% | < 6%"
    end
  end

  def resolve_info_for_insider_deals(share)
    
      return "+1 buy | -1 sell | 0 else"

  end
end
