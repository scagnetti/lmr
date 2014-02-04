require 'engine/util'

# Extracts the latest date and the reaction when quarterly figures were released for a given stock
class OnVistaQuarterlyFiguresExtractor

  SEARCH_URL_PREFIX = "http://www.onvista.de/aktien/dividendenkalender.html?tab=company&cid=id_placeholder&y=year_placeholder"
  EVENTS_WHITE_LIST = ['Ergebnisberichte', 'Unternehmenskonferenzen', 'Hauptversammlung']
  SEARCH_PATTERN_TWO = "//td[contains(., 'Halbjahresabschluss')]/preceding-sibling::td"
  SEARCH_PATTERN_THREE = "//td[contains(., 'ffentlichung des 9-Monats-Berichtes')]/preceding-sibling::td"

  # Load the profile page for a certain stock with the internal onVista sock id 
  def initialize(agent, stock_page)
    @stock_page = stock_page
    @appointment_page = @stock_page.link_with(:text => /Profil\/Termine/).click
    url_with_id = @appointment_page.link_with(:text => /\sWeitere Termine des Unternehmens\s/).href
    # Extract ID (e.g. http://www.onvista.de/aktien/dividendenkalender.html?tab=company&cid=46644)
    match_obj = url_with_id.match(/.*cid=(\d+)$/)
    if match_obj == nil || match_obj[1] == nil
      raise DataMiningError, "Could not extract onVista specific stock id", caller
    end
    share_id = match_obj[1]
    LOG.debug("#{self.class}: OnVista specific stock id: #{share_id}")
    @search_url = SEARCH_URL_PREFIX.sub("id_placeholder", share_id)
    # search for release date back to this year
    last_year = (Time.now.year - 1).to_s
    @search_url = @search_url.sub("year_placeholder", last_year)
    LOG.debug("#{self.class}: Using search URL: #{@search_url}")
    # Delete
    @extended_appointment_page = agent.get(@search_url) 
    LOG.info("#{self.class}: Initialization successful")
  end
  
  # Extract the value of the stock and the value of the index
  # when the quarterly figures were released.
  # http://www.onvista.de/aktien/dividendenkalender.html?tab=company&cid=46827&y=2013
  def extract_release_date()
    dates = Array.new
    events = Array.new
    tag_set = @extended_appointment_page.parser().xpath("(//table)[2]//following-sibling::tr[position()>1]")
    raise DataMiningError, "Could not extract any release dates for quarterly figures", caller if tag_set.nil? || tag_set.size() < 1
    tag_set.each do |tr|
      # This is neccesary to remove HTML escaped whitespace: &nbsp;
      nbsp = Nokogiri::HTML(EscapedCharacters::SPACE).text
      raw_date = tr.xpath("td[1]").first().content().sub(nbsp,'').strip()
      raw_event = tr.xpath("td[3]").first().content().strip()
      date = Util.to_t(raw_date)
      
      # Make sure date is in the past and the event is in the white list
      if date < Time.now && EVENTS_WHITE_LIST.include?(raw_event)
        dates << date
        events << raw_event
      end
    end
    # For debugging only
    #for i in 0..dates.size-1
    #  LOG.debug("#{self.class}: Date: #{dates[i]}, Event: #{events[i]}")
    #end
    begin
      release_date = Util.get_latest(dates)
      LOG.debug("#{self.class}: Last release date: #{release_date}")
    rescue RuntimeError => e
      LOG.warn("#{self.class}: #{e.to_s}")
      raise DataMiningError, "Could not find any quaterly figures for the last 100 days", caller
    end
    return release_date
  end

end