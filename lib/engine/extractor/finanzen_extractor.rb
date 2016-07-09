# encoding: UTF-8
require 'engine/util'
require 'engine/extractor/basic_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'

# This class has the capability to extract allor at least a part of the information neccessary to evaluate
# a stock against the rules defined by Susan Levermann from the Boerse web site.
class FinanzenExtractor < BasicExtractor

  FINANZEN_URL = "http://www.finanzen.net/"
  STOCK_SUCCESS_XPATH = "//div[@id='breadcrumb']/span[2]/a/span"
  STOCK_SUCCESS_VALUE = "Aktien"
  INDEX_SUCCESS_XPATH = "//div[@id='breadcrumb']/span[2]/a/span"
  INDEX_SUCCESS_VALUE = "Indizes"
  SEARCH_FAILURE = "//div[contains(.,'Keine Ergebnisse')]"
  THREE_MONTHS_IN_SECONDS = 60 * 60 * 24 * 31 * 3
  EXCHANGE_MAP = { "Nasdaq" => "NAS", "Tradegate" => "TGT", "Xetra" => "XETRA", "NYSE" => "NYSE"}

  def initialize(share)
    super(FINANZEN_URL, share)
    Rails.logger.debug("#{self.class}: Open finanzen.net with share: #{share.name} (#{share.isin}) and stock index: #{share.stock_index.name} (#{share.stock_index.isin})")
    @stock_page = perform_search("action", '/suchergebnis.asp', "frmAktiensucheTextfeld", share.isin, STOCK_SUCCESS_XPATH, STOCK_SUCCESS_VALUE)
    @index_page = perform_search("action", '/suchergebnis.asp', "frmAktiensucheTextfeld", share.stock_index.isin, INDEX_SUCCESS_XPATH, INDEX_SUCCESS_VALUE)
    @historical_stock_page = open_sub_page('Historisch', 2, 1, @stock_page)
    @historical_index_page = open_sub_page('Historisch', 1, 0, @index_page)
  end

  private

  def extract_stock_value_on(date)
    # Populate hidden field, we need to simulate the AJAX request
    tmp = @agent.get("http://www.finanzen.net/holedaten.asp?strFrag=vdBHTSService")
    token = tmp.body
    Rails.logger.debug("Access token: #{token}") 
    result_page = @historical_stock_page.form_with(:id => /hikuZR/) do |form|
      form.inTag1 = date.day
      form.inMonat1 = date.month
      form.inJahr1 = date.year
      # form.strBoerse = EXCHANGE_MAP[@share.stock_exchange]
      form.field_with(:name => "strBoerse").option_with(:value => EXCHANGE_MAP[@share.stock_exchange]).click
      form.inTag2 = date.day
      form.inMonat2 = date.month
      form.inJahr2 = date.year
      if form["pkBHTs"] == nil
        form.add_field!("pkBHTs", token)
      else
        form.pkBHTs = token
      end
    end.submit
    # result_page = a.submit(f, f.buttons.first)
    search_date = Util.ensure_string(date)
    tmp_xpath = "//h2[contains(.,'Historische Kurse')]/../following-sibling::div//tr/td[.='#{search_date}']/following-sibling::td"
    #tmp_xpath = "/html/body/div/div[6]/div[4]/div[3]/div/div[2]/div/h2[contains(.,'Historische Kurse')]/../following-sibling::div//tr[2]/td"
    tag_set = result_page.parser().xpath(tmp_xpath)
    raise RuntimeError, "Could not find stock price at (#{date}) with xpath: #{tmp_xpath}", caller if tag_set == nil
    raise RuntimeError, "Could not get stock price at (#{date}), because wrong size of result set, expected 6 but found #{tag_set.size()}", caller if tag_set.size() != 5
    Rails.logger.debug("#{self.class}: Found historical stock value for date #{search_date}")  
    Rails.logger.debug("#{self.class}: Opening value #{tag_set[0].content()}")
    Rails.logger.debug("#{self.class}: Closing value #{tag_set[1].content()}")
    opening = Util.l10n_f_k(tag_set[0].content().strip())
    closing = Util.l10n_f_k(tag_set[1].content().strip())
    return [opening, closing]
  end

  # Possible result after doing the search:
  # Datum       Eröffnung   Schluss     Tageshoch   Tagestief
  # 23.05.2014  16.560,35   -           16.613,07   16.544,49
  # 23.04.2014  16.513,73   16.501,65   16.525,99   16.477,28
  def extract_index_value_on(date)
    tmp = @agent.get("http://www.finanzen.net/holedaten.asp?strFrag=vdBHTSService")
    token = tmp.body
    f_date = I18n.l(date, format: :finanzen)
    Rails.logger.debug("#{self.class} Searching for index value on #{f_date}")
    result_page = @historical_index_page.form_with(:id => /hikuZR/) do |form|
      form.inTag1 = date.day
      form.inMonat1 = date.month
      form.inJahr1 = date.year
      form.inTag2 = date.day
      form.inMonat2 = date.month
      form.inJahr2 = date.year
      if form["pkBHTs"] == nil
        form.add_field!("pkBHTs", token)
      else
        form.pkBHTs = token
      end
    end.submit
    #xpath = "/html/body/div/div[6]/div[4]/div[3]/div/div[2]/div/h2[contains(.,'Historische Kursdaten')]/../following-sibling::div//tr[2]/td"
    xpath = "//h2[contains(.,'Historische Kursdaten')]/../following-sibling::div//tr/td[contains(.,'#{f_date}')]/following-sibling::td"
    Rails.logger.debug("#{self.class}: Using XPATH: #{xpath}")
    tag_set = result_page.parser().xpath(xpath)
    if tag_set == nil || tag_set.size != 4
      raise DataMiningError.new("Reaktion auf Quartalszahlen", "Could not get index value for the given date (#{f_date})")
    end
    Rails.logger.debug("#{self.class}: Index value for date #{f_date}, opening: #{tag_set[0].content()}, closing: #{tag_set[1].content()}")  
    opening = Util.l10n_f_k(tag_set[0].content().strip())
    closing = Util.l10n_f_k(tag_set[1].content().strip())
    return [opening, closing]
  end 

  # Extract all release dates of quarterly figures as a list
  def get_release_dates()
    release_dates = Array.new
    appointment_page = open_sub_page('Termine', 3, 2)
    tag_set = appointment_page.parser().xpath("//h2[contains(.,'vergangene Termine')]/../following-sibling::div//tr[position() > 1]")
    if tag_set == nil || tag_set.size() < 1
      raise DataMiningError.new("Reaktion auf Quartalszahlen", "Could no extract release dates of quarterly figures")
      return
    end
    tag_set.each do |tr|
      td_list = tr.xpath('.//td')
      if td_list.size == 4
        if td_list[0].content() == 'Quartalszahlen'
          quartal = td_list[1].content()
          raw_date = td_list[2].content().strip
          date = Util.add_millennium(raw_date)
          release_dates << Util.to_date_time(date)
        elsif td_list[0].content() == 'Jahresabschluss'
          raw_date = td_list[2].content().strip
          date = Util.add_millennium(raw_date)
          release_dates << Util.to_date_time(date)
        end
      end
    end
    return release_dates
  end

  public

  # Extract the reaction on the release of quarterly figures
  def extract_reaction_on_figures(reaction)
    dates = get_release_dates()
    begin
      release_date = Util.get_latest(dates)
      Rails.logger.debug("#{self.class}: Last release date: #{release_date}")
    rescue RuntimeError => e
      Rails.logger.warn("#{self.class}: #{e.to_s}")
      raise DataMiningError.new("Reaktion auf Quartalszahlen", "Could not find any quaterly figures for the last 100 days")
    end
    before_after = Util.calc_compare_dates(release_date)
    reaction.release_date = release_date
    reaction.before = before_after[0]
    reaction.after = before_after[1]
    # Get the value of the stock when quarterly figures where published
    stock_opening_closing = extract_stock_value_on(reaction.before)
    reaction.price_before = stock_opening_closing[1]
    Rails.logger.debug("#{self.class}: Stock price one day before release: #{reaction.price_before}")
    stock_opening_closing = extract_stock_value_on(reaction.after)
    reaction.price_after = stock_opening_closing[1]
    Rails.logger.debug("#{self.class}: Stock price one day after release: #{reaction.price_after}")
    # Get the value of the index when quaterly figures where published
    index_opening_closing = extract_index_value_on(reaction.before)
    reaction.index_before = index_opening_closing[1]
    Rails.logger.debug("#{self.class}: Index value one day before release: #{reaction.index_before}")
    index_opening_closing = extract_index_value_on(reaction.after)
    reaction.index_after = index_opening_closing[1]
    Rails.logger.debug("#{self.class}: Index value one day after release: #{reaction.index_after}")
  end

  # Extract the opinion of the analysts (Analystenmeinungen)
  def extract_analysts_opinion(analysts_opinion)
    analysts_opinion.buy = 0
    analysts_opinion.hold = 0
    analysts_opinion.sell = 0
    page = open_sub_page("Kursziele", 1, 0, @stock_page)
    xp1 = "//div/h2[contains(.,'Diese Analysten')]"
    heading = page.parser().xpath(xp1)
    if heading == nil || heading.size() != 1
      raise DataMiningError.new("Analystenmeinungen", "Could not extract analysts opinion with xpath #{xp1}")
    end
    xp2 = "(//table)[3]//tr[position()>1]"
    tr_set = page.parser().xpath(xp2)
    if tr_set == nil || tr_set.size() < 1
      raise DataMiningError.new("Analystenmeinungen", "Could not extract analysts opinion with xpath #{xp2}")
    end
    Rails.logger.debug("#{self.class}: #{tr_set.size} analysts rated this stock")
    tr_set.each do |tr|
      # Data extraction
      td_set = tr.xpath("child::node()")
      analyst = td_set[0].text()
      raw_date = td_set[6].text()
      release_date = nil
      if raw_date.end_with?("Uhr")
        # Handle scenario where opinion was added today
        release_date = Time.now
      else
        # Release date casting
        string_date = Util.add_millennium(raw_date)
        release_date = Util.to_t(string_date)
      end
      exp = Util.information_expired(release_date, Util::DAY_IN_SECONDS * 92)
      if exp
        Rails.logger.debug("Rating of #{analyst} expired (released: #{Util.format(release_date)})")
      else
        buy = tr.xpath("td[2][@class = 'background_green_white']").size()
        hold = tr.xpath("td[3][@class = 'background_yellow']").size()
        sell = tr.xpath("td[4][@class = 'background_red_white']").size()
        Rails.logger.debug("#{self.class}: Analyst #{analyst} says buy") if buy > 0
        Rails.logger.debug("#{self.class}: Analyst #{analyst} says hold") if hold > 0
        Rails.logger.debug("#{self.class}: Analyst #{analyst} says sell") if sell > 0
        analysts_opinion.buy = analysts_opinion.buy + buy
        analysts_opinion.hold = analysts_opinion.hold + hold
        analysts_opinion.sell = analysts_opinion.sell + sell
      end
    end
    Rails.logger.debug("#{self.class}: analyst opinion buy: #{analysts_opinion.buy}")
    Rails.logger.debug("#{self.class}: analyst opinion hold: #{analysts_opinion.hold}")
    Rails.logger.debug("#{self.class}: analyst opinion sell: #{analysts_opinion.sell}")
  end

  def extract_insider_deals(insider_info)
    insider_trades = open_sub_page('Insidertrades', 1, 0, @stock_page)
    rows = insider_trades.parser().xpath("//h1[contains(.,'Insidertrades bei ')]/../../div[@class='content']/table//tr[position() > 1]")
    Rails.logger.debug("found #{rows.size} insider deals")
    #share = Share.where(:isin => @share.isin).first
    rows.each do |row|
      cells = row.xpath('.//td')
      if cells.size == 6
        d = cells[0].content()
        full_date = Util.add_millenium(d)
        time = Util.to_t(full_date)

        unless Util.information_expired(time, Util::DAY_IN_SECONDS * 92)
          deal = InsiderDeal.new
          deal.occurred = time
          deal.person = cells[1].content()
          deal.quantity = cells[2].content().sub(/\./, '')
          deal.price =Util.l10n_f_k(cells[3].content())
          action = cells[4].content()
          if action == 'Kauf'
            deal.buy!
          elsif action == 'Verkauf'
             deal.sell!
           else
             deal.unknown!
          end
          details = cells[5].xpath("a").first.attr('href')
          deal.link = "#{FINANZEN_URL}#{details[1,details.length-1]}"
          insider_info.insider_deals << deal
          Rails.logger.debug("#{deal.to_s}")
        end
      end
    end
  end

end
