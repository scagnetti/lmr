require 'rubygems'
require 'mechanize'
require 'engine/extractor/mech_patch.rb'
require 'engine/exceptions/unexpected_html_structure.rb'

# Encapsulate the functionality all extractors have in common.
class BasicExtractor

  # Set up the HTML parser, load the web page of the extractor.
  def initialize(extractor_url, share)
    @share = share
    @agent = Util.createAgent()
    @start_page = @agent.get(extractor_url)
  end

  # Search for a given ISIN.
  # * +attribute+ - used xpath attribute to identify the search form
  # * +regexp+ - the value of the xpath attribute
  # * +field_name+ - the name of the field inside the from
  # * +search_pattern+ - the pattern to search for
  # * +success_xpath+ - xpath to check if the search was successful
  # * +success_value+ - value to check if the search was successful
  def perform_search(attribute, regexp, field_name, search_pattern, success_xpath, success_value)
    search_form = @start_page.form_with(attribute => regexp)
    if search_form == nil
      raise UnexpectedHtmlStructure, "#{@share.name}: Could not find any form with attribute >>#{attribute}<< matching search pattern >>#{regexp}<<", caller
    end
    search_form[field_name] = search_pattern
    result = search_form.submit
    success_indicator = result.parser().xpath(success_xpath)
    if success_indicator.nil? || success_indicator.first().nil? || success_indicator.first().content().strip() != success_value
      raise RuntimeError, "Executed search could not find expected value! Seached for: #{search_pattern}, expected to find >>#{success_value}<< with this xpath expression #{success_xpath}", caller
    else
      return result
    end 
  end

  # Open a sub page on the given page by searching for a given link.
  # * +link_text+ - the name of the link
  # * +result_size+ - the expected number of hits
  # * +link_index+ - the index of the link which should be followed
  # * +page+ - the page with the links to search for 
  def open_sub_page(link_text, result_size, link_index, page=@stock_page)
    links = page.links_with(:text => link_text)
    #puts "Found #{links.size} anchors matching #{link_text}"
    return handle_scrape_result(links, link_text, result_size, link_index)
  end

  # Open a sub page on the given page by comparing a given pattern with the href attribute of the link.
  # * +pattern+ - a part of the URL a link is pointing to
  # * +result_size+ - the expected number of hits
  # * +link_index+ - the index of the link which should be followed
  # * +page+ - the page with the links to search for 
  def open_sub_page_by_href(pattern, result_size, link_index, page=@stock_page)
    links = page.links_with(:href => pattern)
    #puts "Found #{links.size} anchors matching #{pattern}"
    return handle_scrape_result(links, pattern, result_size, link_index)
  end

  # Proper error handling if the scraping result is not what we expected.
  # * +links+ a set of extracted links
  # * +pattern+ - what we used for the search
  # * +result_size+ - the expected number of hits
  # * +link_index+ - the index of the link which should be followed
  def handle_scrape_result(links, pattern, result_size, link_index)
    if links == nil || links.size() != result_size
      raise UnexpectedHtmlStructure, "#{@share.name}: Found #{links.size} link(s) matching pattern >>#{pattern}<< but expected #{result_size}", caller
    else
      sub_page = links[link_index].click()
      return sub_page
    end
  end

  # Extract the name of the stock
  def extract_stock_name()
    raise NotImplementedError, "Could not extract name", caller 
  end
  
  # Extract the current price of the stock
  def extract_stock_price()
    raise NotImplementedError, "Could not extract price", caller
  end

  # Extract the Return on Equity (in German: Eigenkapitalrendite)
  def extract_roe(return_on_equity)
    raise NotImplementedError, "Could not extract RoE", caller
  end

  # Extract EBIT-Margin
  def extract_ebit_margin(ebit_margin, financial)
    raise NotImplementedError, "Could not extract EBIT-Margin", caller
  end

  # Extract equity ratio (Eigenkapitalquote)
  def extract_equity_ratio(equity_ratio)
    raise NotImplementedError, "Could not extract equity ration (Eigenkapitalquote)", caller
  end

  # Extract the current price earnings ratio (KGV)
  def extract_current_price_earnings_ratio(current_price_earnings_ratio)
    raise NotImplementedError, "Could not extract current price earnings ratio (KGV)", caller
  end

  # Extract the average price earnings ratio (KGV5)
  def extract_average_price_earnings_ratio(average_price_earnings_ratio)
    raise NotImplementedError, "Could not extract average price earnings ratio (KGV5)", caller
  end

  # Extract the opinion of the analysts (Analystenmeinungen)
  def extract_analysts_opinion(analysts_opinion)
    raise NotImplementedError, "Could not extract analysts opinion", caller
  end

  # Extract the reaction on the release of quarterly figures
  def extract_reaction_on_figures(reaction)
    raise NotImplementedError, "Could not extract Reaction", caller
  end

  # Extract the revision of estimated profits
  def extract_profit_revision(profit_revision)
    raise NotImplementedError, "Could not extract profit revision", caller
  end

  def extract_stock_price_dev_half_year(stock_price_dev_half_year)
    raise NotImplementedError, "Could not extract stock price development half year", caller
  end
  
  def extract_stock_price_dev_one_year(stock_price_dev_one_year)
    raise NotImplementedError, "Could not extract stock price development one year", caller
  end
  
  def extract_three_month_reversal(reversal)
    raise NotImplementedError, "Could not extract three months reversal", caller
  end
  
  def extract_proft_growth(profit_growth)
    raise NotImplementedError, "Could not extract EPS values for profit growth", caller
  end

  def extract_insider_deals(insider_info)
    raise NotImplementedError, "Could not extract Insider Deals", caller
  end
end