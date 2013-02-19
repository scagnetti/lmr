require 'engine/util'

# Extracts the latest date and the reaction when quarterly figures were released for a given stock
class OnVistaQuarterlyFiguresExtractor

  ON_VISTA_APPOINTMENT_URL = 'http://www.onvista.de/aktien/profil.html?ID_OSI='
  THREE_MONTHS_IN_SECONDS = 60 * 60 * 24 * 31 * 3
  # Spelling differs on onVista sometimes: "Quartal>>s<<zahlen" or "Quartalzahlen"
  SEARCH_PATTERN_ONE = "//td[contains(., 'Quartal')]/preceding-sibling::td"
  SEARCH_PATTERN_TWO = "//td[contains(., 'Halbjahresabschluss')]/preceding-sibling::td"
  SEARCH_PATTERN_THREE = "//td[contains(., 'ffentlichung des 9-Monats-Berichtes')]/preceding-sibling::td"

  # Load the profile page for a certain stock with the internal onVista sock id 
  def initialize(agent, on_vista_stock_id)
    LOG.debug("#{self.class}: initialized")
    @appointment_page = agent.get("#{ON_VISTA_APPOINTMENT_URL}#{on_vista_stock_id}")
  end
  
  # Extract the value of the stock and the value of the index
  # when the quarterly figures were released.
  def extract_release_date()
    raw_dates = get_release_dates()
    casted_dates = convert_to_time(raw_dates)
    release_date = get_latest(casted_dates, THREE_MONTHS_IN_SECONDS)
    if release_date == Time.at(0)
      # No release date in the 3 month interval, this is a serious problem
      raise DataMiningError, "Could not find quarterly figures within 3 months", caller
    end
    return release_date
  end
  
  private

  # Extract all release dates of quarterly figures as a list
  def get_release_dates()
    appointments = Array.new
    # First try
    tag_set = @appointment_page.parser().xpath(SEARCH_PATTERN_ONE)
    add_content(tag_set, appointments)
    
    tag_set = @appointment_page.parser().xpath(SEARCH_PATTERN_TWO)
    add_content(tag_set, appointments)
    
    tag_set = @appointment_page.parser().xpath(SEARCH_PATTERN_THREE)
    add_content(tag_set, appointments)
    
    if appointments.size() == 0
      LOG.info "#{self.class}: Could not find any quarterly figures"
    end

    return appointments
  end

  def convert_to_time(dates)
    casted_dates = Array.new
    dates.each do |date|
      casted_dates << Util.to_t(date)
    end
    return casted_dates
  end

  def add_content(tag_set, appointments)
    if tag_set != nil && tag_set.size() > 0
      tag_set.each do |tag|
        LOG.debug("#{self.class}: Quarterly figures released at: #{tag.content()}")
        appointments << tag.content()
      end
    end
    return appointments
  end

  # Check for the latest date which is in the past but newer than a certain threshold
  def get_latest(dates, threshold)
    now = Time.now()
    latest = Time.at(0)
    dates.each do |date|
      diff = now - date
      if diff > 0
        # We are only interested when the date is in the past
        #LOG.debug "Datum #{t.strftime('%Y-%m-%d')} liegt in der Vergangenheit"
        # Check if the information is newer than 3 months
        if diff < threshold
          #LOG.debug "Datum #{t.strftime('%Y-%m-%d')} ist noch keine drei Monate her"
          if date > latest
            latest = date
          end
        end
      else
        #LOG.debug "Datum #{t.strftime('%Y-%m-%d')} liegt in der Zukunft"
      end
    end
    return latest
  end

end