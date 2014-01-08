require 'engine/types/asset_value.rb'
# Provides the functionality of calculating the value
# of an index at a given historical date
class OnVistaIndexValueExtractor
  
  INDEX_VALUE_SEARCH_URL = "http://www.onvista.de/index/historie.html?ID_NOTATION="
  
  def initialize(agent, index_page)
    on_vista_index_id = get_on_vista_index_id(index_page)
    @index_search_page = agent.get("#{INDEX_VALUE_SEARCH_URL}#{on_vista_index_id}")
    LOG.debug("#{self.class}: Initialization successful")
  end
  
  # Return the onVista specific index ID
  def get_on_vista_index_id(index_page)
    match_obj = index_page.uri.to_s.match(/.*-(\d+)$/)
    LOG.debug("#{self.class}: page URI: #{index_page.uri.to_s}")
    if match_obj == nil || match_obj[1] == nil
      raise DataMiningError, "Could not extract onVista specific index id", caller
    end
    return match_obj[1]
  end
  
  # Extract the open and closeing values of an index
  # +historical_date+ the date used to look up the price of the stock
  def extract_index_value_on(historical_date)
    # FIXME should be set to the extracted value, not the wanted
    av = AssetValue.new(historical_date)
    search_date = Util.ensure_string(historical_date)
    # Enter search date
    history_page = @index_search_page.form_with(:action => /^historie\.html\?ID_NOTATION=.*$/) do |f|
      f.DATE = search_date
    end.click_button
    #tag_set = history_page.parser().xpath("//td[starts-with(.,'#{d}')]/following-sibling::td")
    tag_set = history_page.parser().xpath("//input[@name='DATE']/../../../../../../../tr[7]/td/table/tr/td")
    if tag_set == nil || tag_set.size() != 11
      raise DataMiningError, "Could not get an index value for the given date (#{search_date})", caller
    end
    LOG.debug("#{self.class}: Found historical index value for date #{tag_set[0].content()}")
    LOG.debug("#{self.class}: Index opening value #{tag_set[2].content()}")
    LOG.debug("#{self.class}: Index closing value #{tag_set[8].content()}")
    av.opening = Util.l10n_f_k(tag_set[2].content().strip())
    av.closing = Util.l10n_f_k(tag_set[8].content().strip())
    return av
  end
end