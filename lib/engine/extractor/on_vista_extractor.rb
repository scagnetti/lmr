require 'engine/util.rb'
require 'engine/extractor/basic_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/exceptions/invalid_isin_error.rb'
require 'engine/extractor/on_vista_quarterly_figures_extractor.rb'

# This class has the capability to extract all information neccessary to evaluate
# a stock against the rules defined by Susan Levermann from the OnVista web site.
class OnVistaExtractor < BasicExtractor
  
  ON_VISTA_URL = 'http://www.onvista.de/'
  
  SEARCH_FAILURE = "//div[contains(.,'Keine Ergebnisse')]"
  
  STOCK_VALUE_SEARCH_URL = "http://www.onvista.de/aktien/kurse.html?ID_OSI="
  
  INDEX_VALUE_SEARCH_URL = "http://www.onvista.de/index/historie.html?ID_NOTATION="
  
  HISTORY_TOKEN = "#kurshistorie"
  
  def initialize(stock_isin, index_isin)
    super(ON_VISTA_URL)
    LOG.debug("#{self.class} initialized with stock: #{stock_isin} and index: #{index_isin}")
    @stock_page = perform_search("action", '/suche/', "searchValue", stock_isin, SEARCH_FAILURE)
    @on_vista_id = get_on_vista_stock_id()
    @stock_search_page = @agent.get("#{STOCK_VALUE_SEARCH_URL}#{@on_vista_id}#{HISTORY_TOKEN}")
    index_page = perform_search("action", '/suche/', "searchValue", index_isin, SEARCH_FAILURE)
    on_vista_index_id = get_on_vista_index_id(index_page)
    @index_search_page = @agent.get("#{INDEX_VALUE_SEARCH_URL}#{on_vista_index_id}")
    @key_figures_page = open_sub_page('Kennzahlen', 2, 1)
  end

  private

  # Return the onVista specific stock ID
  def get_on_vista_stock_id()
    l = @stock_page.link_with(:href => %r(http://www.onvista.de/aktien/snapshot.html\?ID_OSI=\d+))
    # LOG.debug("@stock_page.uri: #{l.href}")
    match_obj = l.href.to_s.match(/ID_OSI=(\d+)&?/)
    if match_obj == nil || match_obj[1] == nil
      raise DataMiningError, "Could no extract internal stock id", caller
    end
    return match_obj[1]
  end

  # Return the onVista specific index ID
  def get_on_vista_index_id(page)
    match_obj = page.uri.to_s.match(/ID_NOTATION=(\d+)&?/)
    if match_obj == nil || match_obj[1] == nil
      raise DataMiningError, "Could no extract internal index id", caller
    end
    return match_obj[1]
  end

  # Extract the open and closeing values of a stock
  def extract_stock_value_on(historical_date)
    historical_date = Util.ensure_string(historical_date)
    # Enter search date
    history_page = @stock_search_page.form_with(:action => /.*kurshistorie$/) do |f|
      f.DATE  = historical_date
    end.click_button
    tag_set = history_page.parser().xpath("/html/body/div/div/div/div[2]/form/div/table/tr[2]/td")
    if tag_set == nil || tag_set.size() != 5
      raise DataMiningError, "Could not get a stock value for the given date (#{historical_date})", caller
    end
    LOG.debug("#{self.class}: Found historical value for date #{tag_set[0].content()}")  
    LOG.debug("#{self.class}: Opening value #{tag_set[1].content()}")
    LOG.debug("#{self.class}: Closing value #{tag_set[4].content()}")
    opening = Util.l10n_f(tag_set[1].content().strip())
    closing = Util.l10n_f(tag_set[4].content().strip())
    return [opening, closing]
  end
  
  # Extract the open and closeing values of an index
  def extract_index_value_on(historical_date)
    historical_date = Util.ensure_string(historical_date)
    # Enter search date
    history_page = @index_search_page.form_with(:action => /^historie\.html\?ID_NOTATION=.*$/) do |f|
      f.DATE = historical_date
    end.click_button
    #tag_set = history_page.parser().xpath("//td[starts-with(.,'#{d}')]/following-sibling::td")
    tag_set = history_page.parser().xpath("//input[@name='DATE']/../../../../../../../tr[7]/td/table/tr/td")
    if tag_set == nil || tag_set.size() != 11
      raise DataMiningError, "Could not get an index value for the given date (#{historical_date})", caller
    end
    LOG.debug("#{self.class}: Found historical index value for date #{tag_set[0].content()}")
    LOG.debug("#{self.class}: Index opening value #{tag_set[1].content()}")
    LOG.debug("#{self.class}: Index closing value #{tag_set[7].content()}")
    opening = Util.l10n_f_k(tag_set[2].content().strip())
    closing = Util.l10n_f_k(tag_set[8].content().strip())
    return [opening, closing]
  end

  public

  # Extract the name of the stock
  def extract_stock_name()
    scan_result = @stock_page.title().split(/\|/)
    if scan_result.size > 0
      LOG.debug("#{self.class}: Stock name: #{scan_result[0]}")
      return scan_result[0].strip()
    else
      raise DataMiningError, "Search result was not a stock page!", caller 
    end
  end
  
  # Extract the current price of the stock
  def extract_stock_price()
    price_now = -1
    tag_set = @stock_page.parser().xpath("//span[@class='KURSRICHTUNG']/following-sibling::span")
    if tag_set == nil || tag_set.size() != 1
      raise DataMiningError, "Could no extract current stock price", caller
    else
      raw_price_now = tag_set[0].content().strip()
      price_now = Util.l10n_f(raw_price_now)
      LOG.debug("#{self.class}: Stock price: #{price_now}")
    end
    return price_now
  end

  # Extract Return on Equity (RoE) in German: Eigenkapitalrendite
  def extract_roe(return_on_equity)
    roe = 0
    table = @key_figures_page.parser().xpath("//div[contains(.,'Rentabilit')]/following-sibling::table")
    raise DataMiningError, "Could not find >>Rentabilit<<", caller if table.nil? || table.size() < 1
    years = table.xpath("tr[1]/th[position() > 1]")
    raise DataMiningError, "Could not find years", caller if years.nil? || years.size() != 3
    years.each do |y|
      LOG.debug("#{self.class}: #{y.content()}")
    end
    values = table.xpath("tr[contains(.,'Eigenkapitalrendite')]/td[position() > 1]")
    raise DataMiningError, "Could not find >>Eigenkapitalrendite<<", caller if values.nil? || values.size() != 3
    values.each do |v|
      LOG.debug("#{self.class}: #{v.content()}")
    end
    roe = values[0].content().strip()
    year = years[0].content().strip().sub(/e/,'')
    if roe == "n.a."
      # Data for this year is not yet available, so take last year
      roe = values[1].content().strip()
      year = years[1].content().strip().sub(/e/,'')
      raise DataMiningError, "Two years have n.a. as value", caller if roe == "n.a."
    end
    return_on_equity.value = Util.l10n_f(roe)
    return_on_equity.last_year = year
    LOG.debug("#{self.class}: RoE LJ(#{return_on_equity.last_year}): #{return_on_equity.value}")
  end

  # Extract EBIT-Margin
  def extract_ebit_margin(ebit_margin)
    table = @key_figures_page.parser().xpath("//div[contains(.,'Rentabilit')]/following-sibling::table")
    raise DataMiningError, "Could not find >>Rentabilit<<", caller if table.nil? || table.size() < 1
    years = table.xpath("tr[1]/th[position() > 1]")
    raise DataMiningError, "Could not find years", caller if years.nil? || years.size() != 3
    years.each do |y|
      LOG.debug("#{self.class}: #{y.content()}")
    end
    values = table.xpath("tr[contains(.,'EBIT-Marge')]/td[position() > 1]")
    raise DataMiningError, "Could not find >>EBIT-Marge<<", caller if values.nil? || values.size() != 3
    values.each do |v|
      LOG.debug("#{self.class}: #{v.content()}")
    end
    margin = values[0].content().strip().sub(/%/, '')
    year = years[0].content().strip().sub(/e/,'')
    if margin == "n.a."
      # Data for this year is not yet available, so take last year
      margin = values[1].content().strip().sub(/%/, '')
      year = years[1].content().strip().sub(/e/,'')
      raise DataMiningError, "Two years have n.a. as value", caller if margin == "n.a."
    end
    ebit_margin.value = Util.l10n_f(margin)
    ebit_margin.last_year = year
    LOG.debug("#{self.class}: Ebit-Marge LJ(#{ebit_margin.last_year}): #{ebit_margin.value}")
  end

  # Extract equity ratio (Eigenkapitalquote)
  def extract_equity_ratio(equity_ratio)
    table = @key_figures_page.parser().xpath("//div[contains(.,'Bilanzsumme und Kapitalstruktur')]/following-sibling::table")
    raise DataMiningError, "Could not find >>Bilanzsumme und Kapitalstruktur<<", caller if table.nil? || table.size() < 1
    years = table.xpath("tr[1]/th[position() > 1]")
    raise DataMiningError, "Could not find years", caller if years.nil? || years.size() != 3
    years.each do |y|
      LOG.debug("#{self.class}: #{y.content()}")
    end
    values = table.xpath("tr[contains(.,'Eigenkapitalquote')]/td[position() > 1]")
    raise DataMiningError, "Could not find >>Eigenkapitalquote<<", caller if values.nil? || values.size() != 3
    values.each do |v|
      LOG.debug("#{self.class}: #{v.content()}")
    end
    margin = values[0].content().strip()
    year = years[0].content().strip().sub(/e/,'')
    if margin == "n.a."
      # Data for this year is not yet available, so take last year
      margin = values[1].content().strip()
      year = years[1].content().strip().sub(/e/,'')
      raise DataMiningError, "Two years have n.a. as value", caller if margin == "n.a."
    end
    equity_ratio.value = Util.l10n_f(margin)
    equity_ratio.last_year = year
    LOG.debug("#{self.class}: Eigenkapitalquote LJ(#{equity_ratio.last_year}): #{equity_ratio.value}")
  end

  # Extract the current price earnings ratio (KGV)
  def extract_current_price_earnings_ratio(current_price_earnings_ratio)
    years_row = @key_figures_page.parser().xpath("//td[.='Gewinn pro Aktie in EUR']/parent::tr/preceding-sibling::tr/th")
    values_row = @key_figures_page.parser().xpath("//td[.='KGV']/following-sibling::td")
    if values_row == nil || values_row.size() != 5
      raise DataMiningError, "Could not extract current price earnings ratio (KGV)", caller
    else
      raw_value = values_row[1].content().strip()
      current_price_earnings_ratio.value = Util.l10n_f(raw_value)
      current_price_earnings_ratio.this_year = years_row[2].content().strip().sub(/e/, '').to_i
      LOG.debug("#{self.class}: Current price earnings ratio (KGV) #{current_price_earnings_ratio.this_year}: #{current_price_earnings_ratio.value}")
    end
  end

  # Extract the average price earnings ratio (KGV5)
  def extract_average_price_earnings_ratio(average_price_earnings_ratio)
    years_row = @key_figures_page.parser().xpath("//td[.='Gewinn pro Aktie in EUR']/parent::tr/preceding-sibling::tr/th")
    values_row = @key_figures_page.parser().xpath("//td[.='KGV']/following-sibling::td")
    if values_row == nil || values_row.size() != 5
      raise DataMiningError, "Could not extract average price earnings ratio (KGV5)", caller
    else
      average_price_earnings_ratio.next_year = years_row[1].content().strip().sub(/e/, '').to_i
      average_price_earnings_ratio.this_year = years_row[2].content().strip().sub(/e/, '').to_i
      average_price_earnings_ratio.last_year = years_row[3].content().strip().sub(/e/, '').to_i
      average_price_earnings_ratio.two_years_ago = years_row[4].content().strip().sub(/e/, '').to_i
      average_price_earnings_ratio.three_years_ago = years_row[5].content().strip().sub(/e/, '').to_i
      
      average_price_earnings_ratio.value_next_year = Util.l10n_f(values_row[0].content().strip())
      average_price_earnings_ratio.value_this_year = Util.l10n_f(values_row[1].content().strip())
      average_price_earnings_ratio.value_last_year = Util.l10n_f(values_row[2].content().strip())
      average_price_earnings_ratio.value_two_years_ago = Util.l10n_f(values_row[3].content().strip())
      average_price_earnings_ratio.value_three_years_ago = Util.l10n_f(values_row[4].content().strip())

      LOG.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.next_year}: #{average_price_earnings_ratio.value_next_year}")
      LOG.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.this_year}: #{average_price_earnings_ratio.value_this_year}")
      LOG.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.last_year}: #{average_price_earnings_ratio.value_last_year}")
      LOG.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.two_years_ago}: #{average_price_earnings_ratio.value_two_years_ago}")
      LOG.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.three_years_ago}: #{average_price_earnings_ratio.value_three_years_ago}")
    end
  end

  # Extract the opinion of the analysts (Analystenmeinungen)
  def extract_analysts_opinion(analysts_opinion)
    analyzer_page = open_sub_page("Analyzer", 1, 0)
    tag_set = analyzer_page.parser().xpath("//td[@class='BALKEN']")
    if tag_set == nil || tag_set.size() != 3
      raise DataMiningError, "Could not extract analysts opinion", caller
    else
      analysts_opinion.buy = tag_set[0].inner_text().strip().to_i
      analysts_opinion.hold = tag_set[1].inner_text().strip().to_i
      analysts_opinion.sell = tag_set[2].inner_text().strip().to_i
      LOG.debug("#{self.class}: analyst opinion buy: #{analysts_opinion.buy}")
      LOG.debug("#{self.class}: analyst opinion hold: #{analysts_opinion.hold}")
      LOG.debug("#{self.class}: analyst opinion sell: #{analysts_opinion.sell}")
    end
  end

  # Extract the reaction on the release of quarterly figures
  def extract_reaction_on_figures(index_isin, reaction)
    figuresExtractor = OnVistaQuarterlyFiguresExtractor.new(@agent, @on_vista_id)
    reaction.release_date = figuresExtractor.extract_release_date()
    # Get the value of the stock when quarterly figures where published
    stock_opening_closing = extract_stock_value_on(reaction.release_date)
    reaction.price_opening = stock_opening_closing[0]
    reaction.price_closing = stock_opening_closing[1]
    LOG.debug("#{self.class}: reaction stock: #{reaction.price_opening}")
    LOG.debug("#{self.class}: reaction stock: #{reaction.price_closing}")
    # Get the value of the index when quaterly figures where published
    index_opening_closing = extract_index_value_on(reaction.release_date)
    reaction.index_opening = index_opening_closing[0]
    reaction.index_closing = index_opening_closing[1]
    LOG.debug("#{self.class}: reaction index: #{reaction.index_opening}")
    LOG.debug("#{self.class}: reaction index: #{reaction.index_closing}")
  end

  # Extract the revision of estimated profits
  def extract_profit_revision(profit_revision)
    analyzer_page = open_sub_page("Analyzer", 1, 0)
    tag_set = analyzer_page.parser().xpath("//th[.='Revisionen der Empfehlung der letzten 3 Monate']/../../../tbody/tr/td[2]")
    if tag_set == nil || tag_set.size() != 3
      raise DataMiningError, "Could not extract profit revision", caller
    else
      profit_revision.up = tag_set[0].inner_text().strip().to_i
      profit_revision.equal = tag_set[1].inner_text().strip().to_i
      profit_revision.down = tag_set[2].inner_text().strip().to_i
      LOG.debug("#{self.class}: profit revision up: #{profit_revision.up}")
      LOG.debug("#{self.class}: profit revision equal: #{profit_revision.equal}")
      LOG.debug("#{self.class}: profit revision down: #{profit_revision.down}")
    end
  end
  
  # Extract the stock price development for the past half year
  def extract_stock_price_dev_half_year(stock_price_dev_half_year)
    half_a_year_ago = Util.step_back_in_time(183, Time.now)
    open_closing = extract_stock_value_on(half_a_year_ago)
    LOG.debug("#{self.class}: stock value 6 months ago (#{Util.format(half_a_year_ago)}): #{open_closing[1]}")
    stock_price_dev_half_year.value = open_closing[1]
  end
  
  # Extract the stock price development for the past year
  def extract_stock_price_dev_one_year(stock_price_dev_one_year)
    one_year_ago = Util.step_back_in_time(365, Time.now)
    open_closing = extract_stock_value_on(one_year_ago)
    LOG.debug("#{self.class}: stock value 1 year ago (#{Util.format(one_year_ago)}): #{open_closing[1]}")
    stock_price_dev_one_year.value = open_closing[1]
  end
  
  def extract_three_month_reversal(reversal)
    reversal.four_months_ago = Util.subtract_months_from(Time.now, 4)
    reversal.three_months_ago = Util.subtract_months_from(Time.now, 3)
    reversal.two_months_ago = Util.subtract_months_from(Time.now, 2)
    reversal.one_month_ago = Util.subtract_months_from(Time.now, 1)
    LOG.debug("#{self.class}: Four months ago: #{reversal.four_months_ago}")
    LOG.debug("#{self.class}: Three months ago: #{reversal.three_months_ago}")
    LOG.debug("#{self.class}: Two months ago: #{reversal.two_months_ago}")
    LOG.debug("#{self.class}: One month ago: #{reversal.one_month_ago}") 
    
    value_four_months_ago = extract_stock_value_on(reversal.four_months_ago)
    LOG.debug("#{self.class}: Stock four months ago: #{value_four_months_ago[1]}")
    value_three_months_ago = extract_stock_value_on(reversal.three_months_ago)
    LOG.debug("#{self.class}: Stock three months ago: #{value_three_months_ago[1]}")
    value_two_months_ago = extract_stock_value_on(reversal.two_months_ago)
    LOG.debug("#{self.class}: Stock two months ago: #{value_two_months_ago[1]}")
    value_one_month_ago = extract_stock_value_on(reversal.one_month_ago)
    LOG.debug("#{self.class}: Stock one month ago: #{value_one_month_ago[1]}")
    reversal.value_four_months_ago = value_four_months_ago[1]
    reversal.value_three_months_ago = value_three_months_ago[1]
    reversal.value_two_months_ago = value_two_months_ago[1]
    reversal.value_one_month_ago = value_one_month_ago[1]
    
    index_four_months_ago = extract_index_value_on(reversal.four_months_ago)
    LOG.debug("#{self.class}: Index four months ago: #{index_four_months_ago[1]}")
    index_three_months_ago = extract_index_value_on(reversal.three_months_ago)
    LOG.debug("#{self.class}: Index three months ago: #{index_three_months_ago[1]}")
    index_two_months_ago = extract_index_value_on(reversal.two_months_ago)
    LOG.debug("#{self.class}: Index two months ago: #{index_two_months_ago[1]}")
    index_one_month_ago = extract_index_value_on(reversal.one_month_ago)
    LOG.debug("#{self.class}: Index one month ago: #{index_one_month_ago[1]}")
    reversal.index_four_months_ago = index_four_months_ago[1]
    reversal.index_three_months_ago = index_three_months_ago[1]
    reversal.index_two_months_ago = index_two_months_ago[1]
    reversal.index_one_month_ago = index_one_month_ago[1]
  end

  # Extract profit growth in German: Gewinnwachstum
  def extract_profit_growth(profit_growth)
    tag_set = @key_figures_page.parser().xpath("//td[.='Gewinn pro Aktie in EUR']/following-sibling::td")
    if tag_set == nil || tag_set.size() != 5
      raise DataMiningError, "Could not extract EPS values for profit growth", caller
    else
      profit_growth.value_next_year = Util.l10n_f(tag_set[0].content().strip())
      profit_growth.value_this_year = Util.l10n_f(tag_set[1].content().strip())
      LOG.debug("#{self.class}: Profit growth this year: #{profit_growth.value_this_year}")
      LOG.debug("#{self.class}: Profit growth next year: #{profit_growth.value_next_year}")
    end
  end

end
