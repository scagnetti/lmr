require 'engine/types/asset_value.rb'
# Provides the functionality of calculating the value
# of a share at a given historical date
class OnVistaStockValueExtractor

  STOCK_VALUE_SEARCH_URL = "http://www.onvista.de/onvista/times+sales/popup/historische-kurse/"

  def initialize(agent, stock_page, stock_exchange)
    @agent = agent
    @stock_page = stock_page
    @stock_exchange = stock_exchange
    @stock_exchange_id = get_stock_exchange_id()
    @asset_name = get_asset_name()
    Rails.logger.debug("#{self.class}: Initialization successful")
  end

  # Extract the open and closing values of a stock
  def extract_stock_value_on(historical_date)
    # FIXME should be set to the extracted value, not the wanted
    av = AssetValue.new(historical_date)
    search_date = Util.ensure_string(historical_date)
    search_url = construct_search_url(search_date)
    history_page = @agent.get(search_url)
    td_set = history_page.parser().xpath("//span[.='#{search_date}']/../../following-sibling::td")
    raise RuntimeError, "Could not get a stock price for the given date (#{search_date})", caller if td_set.nil? || td_set.size != 5
    av.opening = Util.l10n_f_k(td_set[0].content().strip())
    av.closing = Util.l10n_f_k(td_set[3].content().strip())
    Rails.logger.debug("#{self.class}: Opening value #{av.opening}")
    Rails.logger.debug("#{self.class}: Closing value #{av.closing}")
    return av
  end

  # Removed for testing with rake tasks
  #------
  # private
  #------

  # The stock exchange ID, should look like: '?notationId=37967484'
  def get_stock_exchange_id()
    anchor_set = @stock_page.parser().xpath("//div[@id='exchangesLayer']/ul/li/a[contains(.,'#{@stock_exchange}')]")
    raise RuntimeError, "Could not extract onVista stock exchange ID for #{@stock_exchange}", caller if anchor_set.nil? || anchor_set.size < 1
    stock_exchange_id = anchor_set[0].attr('href').sub(/.*=/, '')
    Rails.logger.debug("#{self.class}: ID of stock exchange #{@stock_exchange}: #{stock_exchange_id}")
    return stock_exchange_id
  end

  # The asset name of the stock,should look like: 'Du-Pont'
  # http://www.onvista.de/aktien/Du-Pont-Aktie-US2635341090
  def get_asset_name()
    uri = @stock_page.canonical_uri()
    match = uri.to_s.match(/.*\/(.*)-Aktie/)
    raise RuntimeError, "Could not extract stock asset name", caller if match.nil?
    Rails.logger.debug("#{self.class}: Stock asset name: #{match[1]}")
    return match[1]
  end
  
  # Construct the search URL to get the stock value for a historical date
  # * +historical_date+ - a date in the past to search a value for (dd.mm.yyyy)
  #
  # Example URL:
  # http://www.onvista.de/onvista/times+sales/popup/historische-kurse/
  # ?notationId=176173
  # &dateStart=16.12.2012
  # &interval=M1
  # &assetName=VW
  # &exchange=Tradegate
  def construct_search_url(historical_date)
    search_url = ""
    search_url << STOCK_VALUE_SEARCH_URL
    search_url << "?notationId=#{@stock_exchange_id}"
    search_url << "&dateStart=#{historical_date}"
    search_url << "&interval=M1"
    search_url << "&assetName=#{@asset_name}"
    search_url << "&exchange=#{@stock_exchange}"
    Rails.logger.debug("#{self.class}: Constructed search URL: #{search_url}")
    return search_url
  end
end