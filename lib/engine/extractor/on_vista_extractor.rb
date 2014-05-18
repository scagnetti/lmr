# encoding: utf-8
require 'engine/util.rb'
require 'engine/extractor/basic_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/exceptions/invalid_isin_error.rb'
require 'engine/extractor/on_vista_quarterly_figures_extractor.rb'
require 'engine/extractor/on_vista_stock_value_extractor.rb'
require 'engine/extractor/on_vista_index_value_extractor.rb'

# This class has the capability to extract all information neccessary to evaluate
# a stock against the rules defined by Susan Levermann from the OnVista web site.
class OnVistaExtractor < BasicExtractor
  
  YEAR = 'year'
  VALUE = 'value'
  PRICE = 'price'
  CURRENCY = 'currency'
  ON_VISTA_URL = 'http://www.onvista.de/'
  SUCCESS_XPATH = "//nav[@class='BREADCRUMB']/ul/li[2]/a"
  SUCCESS_VALUE_STOCK = "Aktien"
  SUCCESS_VALUE_INDEX = "Indizes"

  attr_reader :stock_value_extractor, :index_value_extractor

  def initialize(share)
    super(ON_VISTA_URL, share)
    Rails.logger.debug("#{self.class}: Open OnVista with share: #{share.name} (#{share.isin}) and stock index: #{share.stock_index.name} (#{share.stock_index.isin})")
    @stock_page = perform_search("action", 'http://www.onvista.de/suche/', "searchValue", share.isin, SUCCESS_XPATH, SUCCESS_VALUE_STOCK)
    Rails.logger.debug("#{self.class}: Loaded content of: #{@stock_page.uri.to_s}")
    if using_right_stock_exchange? == false
      switch_stock_exchange()
    end
    @stock_value_extractor = OnVistaStockValueExtractor.new(@agent, @stock_page, @share.stock_exchange)
    index_page = perform_search("action", 'http://www.onvista.de/suche/', "searchValue", share.stock_index.isin, SUCCESS_XPATH, SUCCESS_VALUE_INDEX)
    @index_value_extractor = OnVistaIndexValueExtractor.new(@agent, index_page)
    @key_figures_page = open_sub_page('Fundamental', 1, 0)
    @end_of_business_year = extract_end_of_business_year()
    Rails.logger.debug("#{self.class}: Initialization successful")
  end


  #------
  private
  #------

  # The used default stock exchange must match the stock exchange,
  # required by the the stock settings, otherwise expect currency issues.
  def using_right_stock_exchange?
    span_set = @stock_page.parser().xpath("//div[@id='exchangesLayer']/span/child::text()")
    raise DataMiningError, "Could not extract used stock exchange", caller if span_set.nil? || span_set.size < 1
    found_stock_exchange = span_set[0].content().strip()
    Rails.logger.debug("#{self.class}: Used stock exchange is: #{found_stock_exchange}")
    if found_stock_exchange == @share.stock_exchange
      Rails.logger.debug("#{self.class}: Used stock exchange matches required stock exchange")
      return true
    else
      Rails.logger.debug("#{self.class}: Stock exchange missmatch! Required stock exchange is #{@share.stock_exchange}")
      return false
    end
  end
  
  # Reload the stock page with the required stock exchange
  # which is defined in the settings of the share
  def switch_stock_exchange()
    anchor_set = @stock_page.parser().xpath("//div[@id='exchangesLayer']/ul/li/a[contains(.,'#{@share.stock_exchange}')]")
    raise DataMiningError, "Could not set stock exchange to #{@share.stock_exchange}", caller if anchor_set.nil? || anchor_set.size != 1
    Rails.logger.debug("#{self.class}: Switching stock exchange to #{@share.stock_exchange}")
    uri = @stock_page.uri.to_s << anchor_set[0].attr('href')
    @stock_page = @agent.get(uri)
    Rails.logger.debug("#{self.class}: Loaded content of #{uri}")
  end
  
  # The business year can end at the end of the year or in the middle
  # Should either be '31.12.' or '30.06.' or '30.09.' or '31.07.'
  def extract_end_of_business_year()
    span_set = @key_figures_page.parser().xpath("//span[contains(.,'Geschäftsjahresende')]")
    raise DataMiningError, "Could not extract >>Geschäftsjahresende<< on key figures page", caller if span_set.nil? || span_set.size < 1
    value = span_set[0].content.strip().sub(/Geschäftsjahresende:\s/, '')
    Rails.logger.debug("#{self.class}: End of business year: #{value}")
    return value
  end
  
  # Return the onVista specific stock ID
  # http://www.onvista.de/aktien/BASF-Aktie-DE000BASF111?notation=37886885
  def get_on_vista_stock_id()
    uri = @stock_page.canonical_uri()
    stock_id = uri.to_s.sub(/.*\//, '').sub(/\?.*/, '')
    Rails.logger.debug("#{self.class}: ID of stock: #{stock_id}")
    return stock_id
  end

  # Extract the available publication years for a given key figure
  # * +figure+ - the name of the key figure
  # * +xpath+ - which extracts the publication years
  # * +em+ - estimated matches regarding the number of publication years found
  def extract_years_of_publication_for(figure, xpath, em)
    years_set = @key_figures_page.parser().xpath(xpath)
    raise DataMiningError, "Could not extract >>#{figure}<<, because of missing publication years", caller if years_set.nil? || years_set.size() != em
    # Access the content of the node and remove the 'e' for 'expected'
    years = years_set.map{|x| x.content().strip().sub(/e/,'')}
    # Care about stocks where business ends in the middle of the year
    # Then we have to deal with years like: 14/15  13/14  12/13  11/12
    if @end_of_business_year != '31.12.'
      years = normalize(years)
    end
    years.each do |y|
      Rails.logger.debug("#{self.class}: Searching for #{figure} of the year #{y}")
    end
    return years
  end

  # Extract the available values for a given key figure
  # * +figure+ - the name of the key figure
  # * +xpath+ - which extracts the value of the key figure
  # * +em+ - estimated matches regarding the number of values found
  def extract_values_for(figure, xpath, em)
    values_set = @key_figures_page.parser().xpath(xpath)
    raise DataMiningError, "Could not find >>#{figure}<<", caller if values_set.nil? || values_set.size() != em
    # Access the content of the node and remove any pre- and postfix around the value
    values = values_set.map{|x| x.content().strip().sub(/^+/,'').sub(/$%/,'')}
    values.each do |v|
      Rails.logger.debug("#{self.class}: #{figure} is #{v}")
    end
    return values
  end

  # Find the most recent value that is available. Sometimes in the beginning of a year
  # some values are not accessible yet
  # * +figure+ - the name of the key figure
  # * +years+ - the extracted year for the key figure
  # * +values+ - the extracted values for the key figure
  def find_most_recent(figure, years, values)
    v = values[0]
    y = years[0]
    if v == "n.a." || v == "-"
      # Data for this year is not yet available, so take year before
      v = values[1]
      y = years[1]
      if v == "n.a." || v == "-"
        raise DataMiningError, "Could not extract >>#{figure}<<, because two years have n.a. as value", caller
      else
        Rails.logger.warn("#{self.class}: Figures for #{figure} are not up to date, using figures from the year before!")
      end
    end
    return Hash[YEAR => y, VALUE => v]
  end

  # Find the value of the current year
  # * +figure+ - the name of the key figure
  # * +years+ - the extracted year for the key figure
  # * +values+ - the extracted values for the key figure
  def find_value_for_current_year(figure, years, values)
    find_value_for_given_year(figure, Time.now.year.to_s, years, values)
  end

  # Find the the value for a certain year
  # * +figure+ - the name of the key figure
  # * +year_of_interest+ - the year the value should be extracted for
  # * +years+ - the extracted year for the key figure
  # * +values+ - the extracted values for the key figure
  def find_value_for_given_year(figure, year_of_interest, years, values)
    raise DataMiningError, "Could not extract >>#{figure}<<, because years differ from values in size", caller if years.size != values.size
    i = years.index(year_of_interest)
    raise DataMiningError, "Could not extract >>#{figure}<<, because year of interest (#{year_of_interest}) could not be found in #{years.to_s}", caller if i.nil?
    year = years[i]
    value = values[i]
    return Hash[YEAR => year, VALUE => value]
  end

  # Years can occur in different forms like: '2012' or '11/12'
  # This method transforms items like '11/12' into '2012'. 
  # * +years+ - the years that need to be normalized
  def normalize(years)
      return years.map {|x| x.sub(/\d{2}\//, Time.now.year.to_s[0,2])}
  end


  #-----
  public
  #-----

  # Extract the name of the stock
  def extract_stock_name()
    scan_result = @stock_page.title().split(/\|/)
    if scan_result.size > 0
      Rails.logger.debug("#{self.class}: Stock name: #{scan_result[0]}")
      return scan_result[0].strip()
    else
      raise DataMiningError, "Search result was not a stock page!", caller 
    end
  end
  
  # Extract the current price of the stock
  def extract_stock_price()
    price_now = -1
    currency = 'not set'
    tag_set = @stock_page.parser().xpath("//ul[@class='KURSDATEN']/li[1]/span")
    raise DataMiningError, "Could not extract current stock price", caller if tag_set.nil? || tag_set.size() != 2
    raw_price_now = tag_set[0].content().strip()
    currency = tag_set[1].content().strip()
    price_now = Util.l10n_f_k(raw_price_now)
    Rails.logger.debug("#{self.class}: Stock price: #{price_now} #{currency}")
    return Hash[PRICE => price_now, CURRENCY => currency]
  end


  ###############################
  # Levermann rating algorithms #
  ###############################

  # Extract Return on Equity (RoE) in German: Eigenkapitalrendite
  # ruby -I test test/integration/extract_roe_test.rb
  def extract_roe(return_on_equity)
    figure = "Eigenkapitalrendite"
    years_xpath = "(//th[contains(.,'Rentabilit')])[2]/following-sibling::th[position() > 3]"
    values_xpath = "//td[.='Eigenkapitalrendite']/following-sibling::td[position() > 3]"
    years = extract_years_of_publication_for(figure, years_xpath, 4)
    values = extract_values_for(figure, values_xpath, 4)
    result = find_most_recent(figure, years, values)
    return_on_equity.value = Util.l10n_f(result[VALUE])
    return_on_equity.last_year = result[YEAR]
    Rails.logger.debug("#{self.class}: RoE LJ (#{return_on_equity.last_year}): #{return_on_equity.value}")
  end


  # Extract EBIT-Margin
  # ruby -I test test/integration/extract_ebit_test.rb
  def extract_ebit_margin(ebit_margin)
    figure = "EBIT-Marge"
    years_xpath = "(//th[contains(.,'Rentabilit')])[2]/following-sibling::th[position() > 3]"
    values_xpath = "//td[.='EBIT-Marge']/following-sibling::td[position() > 3]"
    years = extract_years_of_publication_for(figure, years_xpath, 4)
    values = extract_values_for(figure, values_xpath, 4)
    result = find_most_recent(figure, years, values)
    ebit_margin.value = Util.l10n_f(result[VALUE])
    ebit_margin.last_year = result[YEAR]
    Rails.logger.debug("#{self.class}: Ebit-Marge LJ(#{ebit_margin.last_year}): #{ebit_margin.value}")
  end


  # Extract equity ratio (Eigenkapitalquote)
  # ruby -I test test/integration/extract_equity_ratio_test.rb
  def extract_equity_ratio(equity_ratio)
    figure = "Eigenkapitalquote"
    years_xpath = "(//th[contains(.,'Bilanz')])[2]/following-sibling::th[position() > 3]"
    values_xpath = "//td[.='Eigenkapitalquote']/following-sibling::td[position() > 3]"
    years = extract_years_of_publication_for(figure, years_xpath, 4)
    values = extract_values_for(figure, values_xpath, 4)
    result = find_most_recent(figure, years, values)
    equity_ratio.value = Util.l10n_f(result[VALUE])
    equity_ratio.last_year = result[YEAR]
    Rails.logger.debug("#{self.class}: Eigenkapitalquote LJ(#{equity_ratio.last_year}): #{equity_ratio.value}")
  end

  # Extract the current price earnings ratio (KGV)
  # ruby -I test test/integration/extract_current_price_earnings_test.rb
  def extract_current_price_earnings_ratio(current_price_earnings_ratio)
    figure = "KGV aktuell"
    years_xpath = "(//th[contains(.,'Gewinn')])[1]/following-sibling::th"
    values_xpath = "//td[.='KGV']/following-sibling::td"
    years = extract_years_of_publication_for(figure, years_xpath, 7)
    values = extract_values_for(figure, values_xpath, 7)
    result = find_value_for_current_year(figure, years, values)
    current_price_earnings_ratio.value = Util.l10n_f(result[VALUE])
    current_price_earnings_ratio.this_year = result[YEAR]
    Rails.logger.debug("#{self.class}: Current price earnings ratio (KGV) #{current_price_earnings_ratio.this_year}: #{current_price_earnings_ratio.value}")
  end

  # Extract the average price earnings ratio (KGV 5 Jahre)
  # ruby -I test test/integration/extract_average_price_earnings_test.rb
  def extract_average_price_earnings_ratio(average_price_earnings_ratio)
    figure = "KGV 5 Jahre"
    years_xpath = "(//th[contains(.,'Gewinn')])[1]/following-sibling::th"
    values_xpath = "//td[.='KGV']/following-sibling::td"
    years = extract_years_of_publication_for(figure, years_xpath, 7)
    values = extract_values_for(figure, values_xpath, 7)

    average_price_earnings_ratio.next_year = years[1].to_i
    average_price_earnings_ratio.this_year = years[2].to_i
    average_price_earnings_ratio.last_year = years[3].to_i
    average_price_earnings_ratio.two_years_ago = years[4].to_i
    average_price_earnings_ratio.three_years_ago = years[5].to_i
    
    average_price_earnings_ratio.value_next_year = Util.l10n_f_k(values[1])
    average_price_earnings_ratio.value_this_year = Util.l10n_f_k(values[2])
    average_price_earnings_ratio.value_last_year = Util.l10n_f_k(values[3])
    average_price_earnings_ratio.value_two_years_ago = Util.l10n_f_k(values[4])
    average_price_earnings_ratio.value_three_years_ago = Util.l10n_f_k(values[5])

    Rails.logger.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.next_year}: #{average_price_earnings_ratio.value_next_year}")
    Rails.logger.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.this_year}: #{average_price_earnings_ratio.value_this_year}")
    Rails.logger.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.last_year}: #{average_price_earnings_ratio.value_last_year}")
    Rails.logger.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.two_years_ago}: #{average_price_earnings_ratio.value_two_years_ago}")
    Rails.logger.debug("#{self.class}: Price earnings ratio (KGV) #{average_price_earnings_ratio.three_years_ago}: #{average_price_earnings_ratio.value_three_years_ago}")
  end

  # Extract the opinion of the analysts (Analystenmeinungen)
  # ruby -I test test/integration/extract_analysts_opinion_test.rb
  def extract_analysts_opinion(analysts_opinion)
    analyzer_page = open_sub_page("Analyzer", 1, 0)
    tag_set = analyzer_page.parser().xpath("//td[@class='BALKEN']")
    if tag_set == nil || tag_set.size() != 5
      raise DataMiningError, "Could not extract analysts opinion", caller
    else
      analysts_opinion.buy = tag_set[0].inner_text().strip().to_i + tag_set[1].inner_text().strip().to_i
      analysts_opinion.hold = tag_set[2].inner_text().strip().to_i
      analysts_opinion.sell = tag_set[3].inner_text().strip().to_i + tag_set[4].inner_text().strip().to_i
      Rails.logger.debug("#{self.class}: analyst opinion buy: #{analysts_opinion.buy}")
      Rails.logger.debug("#{self.class}: analyst opinion hold: #{analysts_opinion.hold}")
      Rails.logger.debug("#{self.class}: analyst opinion sell: #{analysts_opinion.sell}")
    end
  end

  # Extract the reaction on the release of quarterly figures
  # ruby -I test test/integration/extract_reaction_on_figures_test.rb
  def extract_reaction_on_figures(reaction)
    figuresExtractor = OnVistaQuarterlyFiguresExtractor.new(@agent, @stock_page)
    dates = figuresExtractor.extract_relevant_dates()
    reaction.release_date = dates['release']
    reaction.before = dates['before']
    reaction.after = dates['after']
    # Get the value of the stock one day before the quarterly figures where published
    asset_value = @stock_value_extractor.extract_stock_value_on(reaction.before)
    reaction.price_before = asset_value.closing()
    Rails.logger.debug("#{self.class}: Stock price one day before release: #{reaction.price_before}")
    # Get the value of the stock one day after the quarterly figures where published
    asset_value = @stock_value_extractor.extract_stock_value_on(reaction.after)
    reaction.price_after = asset_value.closing()
    Rails.logger.debug("#{self.class}: Stock price one day after release: #{reaction.price_after}")
    # Get the value of the index one day before the quaterly figures where published
    asset_value = @index_value_extractor.extract_index_value_on(reaction.before)
    reaction.index_before = asset_value.closing()
    Rails.logger.debug("#{self.class}: Index value one day before release: #{reaction.index_before}")
    # Get the value of the index one day after the quaterly figures where published
    asset_value = @index_value_extractor.extract_index_value_on(reaction.after)
    reaction.index_after = asset_value.closing()
    Rails.logger.debug("#{self.class}: Index value one day after release: #{reaction.index_after}")
  end

  # Extract the revision of estimated profits
  # ruby -I test test/integration/extract_profit_revision_test.rb
  def extract_profit_revision(profit_revision)
    ## This way doesn't work with american shares like DOW, because no values are found
    # analyzer_page = open_sub_page("Analyzer", 1, 0)
    # tag_set = analyzer_page.parser().xpath("//th[.='Revisionen der Empfehlung der letzten 3 Monate']/../../../tbody/tr/td[2]")
    # if tag_set == nil || tag_set.size() != 3
      # raise DataMiningError, "Could not extract profit revision", caller
    # else
      # profit_revision.up = tag_set[0].inner_text().strip().to_i
      # profit_revision.equal = tag_set[1].inner_text().strip().to_i
      # profit_revision.down = tag_set[2].inner_text().strip().to_i
      # Rails.logger.debug("#{self.class}: profit revision up: #{profit_revision.up}")
      # Rails.logger.debug("#{self.class}: profit revision equal: #{profit_revision.equal}")
      # Rails.logger.debug("#{self.class}: profit revision down: #{profit_revision.down}")
    # end
    # This way works also with american shares like DOW
    tag_set = @stock_page.parser().xpath("//th[contains(.,'Revidierte Gewinnprognose')]/following-sibling::td[1]/span[1]")
    raise DataMiningError, "Could not extract profit revision", caller if tag_set == nil || tag_set.size() != 1
    assessment = tag_set[0].attr('class')
    Rails.logger.debug("#{self.class}: profit revision: #{assessment}")
    case assessment
    when "KAUFEN"
      profit_revision.up = 1
      profit_revision.equal = 0
      profit_revision.down = 0
    when "HALTEN"
      profit_revision.up = 0
      profit_revision.equal = 1
      profit_revision.down = 0
    when "VERKAUFEN"
      profit_revision.up = 0
      profit_revision.equal = 0
      profit_revision.down = 1
    else
      raise DataMiningError, "Don't know how to interpret profit revision: #{assessment}", caller
    end
    Rails.logger.debug("#{self.class}: profit revision up: #{profit_revision.up}")
    Rails.logger.debug("#{self.class}: profit revision equal: #{profit_revision.equal}")
    Rails.logger.debug("#{self.class}: profit revision down: #{profit_revision.down}")
  end
  
  # Extract the stock price development for the last half year
  # ruby -I test test/integration/extract_stock_price_dev_half_year_test.rb
  def extract_stock_price_dev_half_year(stock_price_dev_half_year)
    half_a_year_ago = Util.step_back_in_time(183, Time.now)
    stock_price_dev_half_year.historical_date = half_a_year_ago 
    asset_value = @stock_value_extractor.extract_stock_value_on(half_a_year_ago)
    Rails.logger.debug("#{self.class}: stock value 6 months ago (#{Util.format(half_a_year_ago)}): #{asset_value.closing()}")
    stock_price_dev_half_year.value = asset_value.closing()
  end
  
  # Extract the stock price development for the last year
  # ruby -I test test/integration/extract_stock_price_dev_one_year_test.rb
  def extract_stock_price_dev_one_year(stock_price_dev_one_year)
    one_year_ago = Util.step_back_in_time(365, Time.now)
    stock_price_dev_one_year.historical_date = one_year_ago
    asset_value = @stock_value_extractor.extract_stock_value_on(one_year_ago)
    Rails.logger.debug("#{self.class}: stock value 1 year ago (#{Util.format(one_year_ago)}): #{asset_value.closing}")
    stock_price_dev_one_year.value = asset_value.closing()
  end
  
  # Extract the stock price and the index value for the last four months
  # ruby -I test test/integration/extract_three_month_reversal_test.rb
  def extract_three_month_reversal(reversal)
    historical_date = Util.avoid_weekend(Time.now - 4.months)
    asset_value = @stock_value_extractor.extract_stock_value_on(historical_date)
    reversal.value_four_months_ago = asset_value.closing()
    reversal.four_months_ago = asset_value.representing_date()
    Rails.logger.debug("#{self.class}: Stock price four months ago (#{reversal.four_months_ago}): #{reversal.value_four_months_ago}")
    historical_date = Util.avoid_weekend(Time.now - 3.months)
    asset_value = @stock_value_extractor.extract_stock_value_on(historical_date)
    reversal.value_three_months_ago = asset_value.closing()
    reversal.three_months_ago = asset_value.representing_date()
    Rails.logger.debug("#{self.class}: Stock price three months ago (#{reversal.three_months_ago}): #{reversal.value_three_months_ago}")
    historical_date = Util.avoid_weekend(Time.now - 2.months)
    asset_value = @stock_value_extractor.extract_stock_value_on(historical_date)
    reversal.value_two_months_ago = asset_value.closing()
    reversal.two_months_ago = asset_value.representing_date()
    Rails.logger.debug("#{self.class}: Stock price two months ago (#{reversal.two_months_ago}): #{reversal.value_two_months_ago}")
    historical_date = Util.avoid_weekend(Time.now - 1.month)
    asset_value = @stock_value_extractor.extract_stock_value_on(historical_date)
    reversal.value_one_month_ago = asset_value.closing()
    reversal.one_month_ago = asset_value.representing_date()
    Rails.logger.debug("#{self.class}: Stock price one month ago (#{reversal.one_month_ago}): #{reversal.value_one_month_ago}")
    # Calculate the values for the corresponding index at the same dates
    asset_value = @index_value_extractor.extract_index_value_on(reversal.four_months_ago)
    reversal.index_four_months_ago = asset_value.closing()
    Rails.logger.debug("#{self.class}: Index four months ago (#{reversal.four_months_ago}): #{reversal.index_four_months_ago}")
    asset_value = @index_value_extractor.extract_index_value_on(reversal.three_months_ago)
    reversal.index_three_months_ago = asset_value.closing()
    Rails.logger.debug("#{self.class}: Index three months ago (#{reversal.three_months_ago}): #{reversal.index_three_months_ago}")
    asset_value = @index_value_extractor.extract_index_value_on(reversal.two_months_ago)
    reversal.index_two_months_ago = asset_value.closing()
    Rails.logger.debug("#{self.class}: Index two months ago (#{reversal.two_months_ago}): #{reversal.index_two_months_ago}")
    asset_value = @index_value_extractor.extract_index_value_on(reversal.one_month_ago)
    reversal.index_one_month_ago = asset_value.closing()
    Rails.logger.debug("#{self.class}: Index one month ago (#{reversal.one_month_ago}): #{reversal.index_one_month_ago}")
  end

  # Extract profit growth (Gewinnwachstum)
  # ruby -I test test/integration/extract_profit_growth_test.rb
  def extract_profit_growth(profit_growth)
    figure = "Gewinnwachstum"
    years_xpath = "(//th[contains(.,'Gewinn')])[1]/following-sibling::th"
    values_xpath = "//td[.='Gewinn pro Aktie in EUR']/following-sibling::td"
    years = extract_years_of_publication_for(figure, years_xpath, 7)
    values = extract_values_for(figure, values_xpath, 7)
    profit_growth.this_year = Time.now.year
    value_this_year = find_value_for_given_year(figure, profit_growth.this_year.to_s, years, values)
    profit_growth.next_year = profit_growth.this_year + 1
    value_next_year = find_value_for_given_year(figure, profit_growth.next_year.to_s, years, values) 
    profit_growth.value_this_year = Util.l10n_f(value_this_year[VALUE])
    profit_growth.value_next_year = Util.l10n_f(value_next_year[VALUE])
    Rails.logger.debug("#{self.class}: Profit growth this year: #{profit_growth.value_this_year}")
    Rails.logger.debug("#{self.class}: Profit growth next year: #{profit_growth.value_next_year}")
  end

end
