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
  
end
