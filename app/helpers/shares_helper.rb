module SharesHelper
  
  def to_readable_comp_size(i)
    case i
    when CompanySize::LARGE
      return I18n.t(:large_cap)
    when CompanySize::MID
      return  I18n.t(:mid_cap)
    when CompanySize::SMALL
      return I18n.t(:small_cap)
    else
      return "unknown"
    end
  end
  
  def assemble_url(share)
    return "'shares/enable/#{share.isin}/#{!share.active}'"
  end
  
  # Assemble data for display as chart
  # The dates look like this ["5/1/2010", "5/2/2010", "5/3/2010", "5/4/2010", "5/5/2010"]
  def get_chart_data()
    data = Array.new
    # Limit to 10 score cards
    score_cards = @share.score_cards.length > 10 ? @share.score_cards.last(10) : @share.score_cards
    score_cards.each do |score_card|
      data << {:created_at => I18n.l(score_card.created_at), :total_score => score_card.total_score}
    end
    return data.to_json
  end
  
  # When a value is clicked inside the chart
  # we want to open the corresponding score card
  # but we just have the index of the clicked value.
  # So we use this table to look up the score card ID
  def get_score_card_ids()
    score_card_ids = Array.new
    # Limit to 10 score cards
    score_cards = @share.score_cards.length > 10 ? @share.score_cards.last(10) : @share.score_cards
    score_cards.each do |score_card|
      score_card_ids << score_card.id
    end
    return score_card_ids
  end

  # Get the data for display with chart.js
  def get_data_for_chartjs()
    data = Hash.new
    labels = Array.new
    values = Array.new
    data_set = Hash.new
    data_sets = Array.new
    data_sets << data_set
    
    data["labels"] = labels
    data["datasets"] = data_sets
    
    data_set["fillColor"] = "rgba(151,187,205,0.5)"
    data_set["strokeColor"] = "rgba(151,187,205,1)"
    data_set["pointColor"] = "rgba(151,187,205,1)"
    data_set["pointStrokeColor"] = "#fff"
    data_set["data"] = values
    
    data_sets << data_set
    
    # Limit to 10 score cards
    score_cards = @share.score_cards.length > 10 ? @share.score_cards.last(10) : @share.score_cards
    score_cards.each do |score_card|
      labels << I18n.l(score_card.created_at)
      values << score_card.total_score
    end
    return data.to_json
  end

end