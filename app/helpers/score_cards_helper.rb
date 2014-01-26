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
  
  def get_deal_type(code)
    case code
    when Transaction::SELL
      string_repesentation = "Sell"
    when Transaction::BUY
      string_repesentation = "Buy"
    when Transaction::UNKNOWN
      string_repesentation = "Unknown"
    else
      string_repesentation = "Check logic!"
    end
  end
end
