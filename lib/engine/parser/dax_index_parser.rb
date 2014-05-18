require 'rubygems'
require 'mechanize'
require 'engine/exceptions/unexpected_html_structure.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/parser/basic_index_parser.rb'

# require 'engine/parser/dax_index_parser.rb'
# This class is capable of parsing the DAX index at the onVista homepage,
# create a Share object for each entry and save the populated object to the database. 
class DaxIndexParser < BasicIndexParser

  URL_DAX = "http://www.onvista.de/index/einzelwerte.html?ID_NOTATION=20735"
  
  def initialize()
    super()
    @stock_index = StockIndex.where("name LIKE ?", "DAX").first
    stock_listing = get_entries_of_index(URL_DAX, 30)
    process_dax_entries(stock_listing)
  end

  public

  def process_dax_entries(stock_listing)
    stock_listing.each do |row|
      share = create_share()
      Rails.logger.debug("{self.class}: #{row.content()}")
      td_set = row.xpath("td")
      if td_set == nil || td_set.size() != 9
        raise DataMiningError, "Row did't have the expected number of 9 cells", caller
      end
      Rails.logger.debug("#{self.class}: Content of third cell #{td_set[2].content()}")
      # Remove UNICODE white space
      raw_stock_exchange = td_set[2].content().gsub(/[[:space:]]/, '')
      share.stock_exchange = map_stock_exchange(raw_stock_exchange)
      Rails.logger.debug("#{self.class}: Assigned stock exchange: #{share.stock_exchange}")
      #Extract link to stock page
      stock_link = td_set[0].xpath("a").first.attr("href")
      Rails.logger.debug("#{self.class}: Following link: #{stock_link}.")
      extract_data_from_stock_page(stock_link, share)
      if share.save
        Rails.logger.debug("#{self.class}: Create share with ID #{share.id} successfully!")
      else
        Rails.logger.debug("#{self.class}: Failed to save share #{share.name}!")
      end
    end
  end

  private

  def create_share
    share = Share.new
    share.active = true
    share.financial = false
    share.size = CompanySize::LARGE
    share.currency = Currency::EUR
    share.stock_index = @stock_index
    return share
  end

  def extract_data_from_stock_page(stock_link, share)
    page = @agent.get(stock_link)
    # ===NAME===
    result = page.parser().xpath("//a[@class = 'INSTRUMENT']/text()")
    if result == nil || result.size != 2
      raise DataMiningError, "Wrong number of matching links, expecting exact one", caller
    end
    share.name = result[0].content().gsub(/[[:space:]]/, '')
    Rails.logger.debug("Stock name: #{share.name}")
    # ===ISIN===
    result = page.parser().xpath("//dd[@itemprop='productID']")
    if result == nil || result.size != 2
      raise DataMiningError, "Found too many tags with attribute 'itemprop=productID', expected two matches", caller
    end
    share.isin = result[0].content().gsub(/[[:space:]]/, '')
    Rails.logger.debug("Stock ISIN: #{share.isin}")
  end
end