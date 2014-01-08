# encoding: UTF-8
require 'engine/util'
require 'engine/extractor/basic_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/exceptions/invalid_isin_error.rb'

# This class has the capability to extract all information neccessary to evaluate
# a stock against the rules defined by Susan Levermann from the Boerse web site.
class BoerseExtractor < BasicExtractor

  BOERSE_URL = "http://www.boerse.de/"
  
  SEARCH_FAILURE = "//div[contains(.,'Leider konnten wir keine Wertpapiere für Ihre Anfrage finden')]"

  def initialize(share)
    super(BOERSE_URL, share)
    LOG.debug("#{self.class}: initialized")
    #TODO update!
    @stock_page = perform_search("action", '/suche/', "search", stock_isin, SEARCH_FAILURE)
  end

  private



  public

  # Extract the name of the stock
  def extract_stock_name()
    scan_result = @stock_page.title().split(/\|/)
    if scan_result.size > 0
      LOG.debug("#{self.class}: Stock name: #{scan_result[0]}")
      return scan_result[0]
    else
      raise DataMiningError, "Search result was not a stock page!", caller 
    end
  end
  
  # Extract the current price of the stock
  def extract_stock_price()
    price_now = -1
    tag_set = @stock_page.parser().xpath("//h3[contains(.,'Aktienkurs')]/following::h1[1]")
    if tag_set == nil || tag_set.size() != 1
      raise DataMiningError, "Could no extract current stock price", caller
    else
      raw_price_now = tag_set[0].content().strip()
      price_now = Util.l10n_f(raw_price_now)
      LOG.debug("#{self.class}: Stock price: #{price_now}")
    end
    return price_now
  end

  # Extract the Return on Equity (RoE) in German: Eigenkapitalrendite
  def extract_roe(return_on_equity)
    key_figures_page = open_sub_page('Fundamental', 1, 0)
    roe = 1000
    tag_set = key_figures_page.parser().xpath("//td[.='Eigenkapitalrendite']/following-sibling::td")
    if tag_set == nil || tag_set.size() != 9
      raise DataMiningError, "Could not extract RoE", caller
    else
      raw_roe = tag_set[8].content().strip()
      raise DataMiningError, "Could not extract RoE", caller if raw_roe == "n.a."
      roe = Util.l10n_f(raw_roe)
      LOG.debug("#{self.class}: RoE LJ: #{roe}")
    end
    return_on_equity.value = roe
  end

end