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
  
  def get_dates()
    dates = Array.new
    @share.score_cards.each do |score_card|
      dates << I18n.l(score_card.created_at)
    end
    # puts "Dates: #{dates}"
    return dates #["5/1/2010", "5/2/2010", "5/3/2010", "5/4/2010", "5/5/2010"]
  end
  
  def get_scores()
    scores = Array.new
    @share.score_cards.each do |score_card|
      scores << score_card.total_score
    end
    # puts "Scores: #{scores}"
    return scores #[-13, 2, 4, 9, 13]
  end
end
