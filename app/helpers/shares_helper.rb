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
    @share.score_cards.each do |score_card|
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
    @share.score_cards.each do |score_card|
      score_card_ids << score_card.id
    end
    return score_card_ids
  end
end
