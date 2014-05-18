# Ecapsulates alle basic functionality for parsing an index on the onVista homepage.
class BasicIndexParser
  
  def initialize()
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Firefox'
      agent.open_timeout=60000
      agent.read_timeout=60000
    end
  end

  # Extract all entries of the given index URL
  # +url+ - the homepage of the index with listed entries
  # +exp_size+ - the estimated number of items on the first page
  def get_entries_of_index(url, exp_size)
    page = @agent.get(url)
    tr_set = page.parser().xpath("(//table)[5]//tr[(position() > 2)]")
    if tr_set == nil || tr_set.size() != exp_size
      raise DataMiningError, "Could not extract index entries", caller
    else
      Rails.logger.debug("#{self.class}: Found #{tr_set.size()} entries.")
    end
    return tr_set
  end
  
  def map_stock_exchange(raw_value)
    case raw_value
    when StockExchange::TRADEGATE
      return StockExchange::TRADEGATE
    when StockExchange::XETRA
      return StockExchange::XETRA
    when StockExchange::NYSE
      return StockExchange::NYSE
    when StockExchange::NASDAQ
      return StockExchange::NASDAQ
    else
    raise DataMiningError, "Could not find a matching sotck exchange for #{raw_value}", caller
    end
  end
  

end