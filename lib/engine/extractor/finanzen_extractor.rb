# encoding: UTF-8
require 'engine/util'
require 'engine/extractor/basic_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/exceptions/invalid_isin_error.rb'

# This class has the capability to extract allor at least a part of the information neccessary to evaluate
# a stock against the rules defined by Susan Levermann from the Boerse web site.
class FinanzenExtractor < BasicExtractor

  FINANZEN_URL = "http://www.finanzen.net/"
  STOCK_SUCCESS_XPATH = "//div[@class='breadcrumb']/a[2]"
  STOCK_SUCCESS_VALUE = "Aktien"
  INDEX_SUCCESS_XPATH = "//div[@class='breadcrumb']/a[2]"
  INDEX_SUCCESS_VALUE = "Indizes"
  SEARCH_FAILURE = "//div[contains(.,'Keine Ergebnisse')]"
  THREE_MONTHS_IN_SECONDS = 60 * 60 * 24 * 31 * 3

  def initialize(share)
    super(FINANZEN_URL, share)
    LOG.debug("#{self.class}: Open finanzen.net with share: #{share.name} (#{share.isin}) and stock index: #{share.stock_index.name} (#{share.stock_index.isin})")
    @stock_page = perform_search("action", '/suchergebnis.asp', "frmAktiensucheTextfeld", share.isin, STOCK_SUCCESS_XPATH, STOCK_SUCCESS_VALUE)
    @index_page = perform_search("action", '/suchergebnis.asp', "frmAktiensucheTextfeld", share.stock_index.isin, INDEX_SUCCESS_XPATH, INDEX_SUCCESS_VALUE)
    @historical_stock_page = open_sub_page('Historisch', 2, 1, @stock_page)
    @historical_index_page = open_sub_page('Historisch', 1, 0, @index_page)
  end

  private

  def extract_stock_value_on(date)
    result_page = @historical_stock_page.form_with(:action => /\/kurse\/kurse_historisch\.asp/) do |form|
      form.dtTag1 = date.day
      form.dtMonat1 = date.month
      form.dtJahr1 = date.year
      
      form.dtTag2 = date.day
      form.dtMonat2 = date.month
      form.dtJahr2 = date.year
    end.submit
    tag_set = result_page.parser().xpath("//h2[contains(.,'Historische Kurse')]/../following-sibling::div//tr[2]/td")
    if tag_set == nil || tag_set.size() != 6
      raise DataMiningError, "Could not get a stock value for the given date (#{date})", caller
    end
    LOG.debug("#{self.class}: Found historical stock value for date #{tag_set[0].content()}")  
    LOG.debug("#{self.class}: Opening value #{tag_set[1].content()}")
    LOG.debug("#{self.class}: Closing value #{tag_set[2].content()}")
    opening = Util.l10n_f(tag_set[1].content().strip())
    closing = Util.l10n_f(tag_set[2].content().strip())
    return [opening, closing]
  end

  def extract_index_value_on(date)
    result_page = @historical_index_page.form_with(:id => /frmHistorisch/) do |form|
      form.dtTag1 = date.day
      form.dtMonat1 = date.month
      form.dtJahr1 = date.year
      
      form.dtTag2 = date.day
      form.dtMonat2 = date.month
      form.dtJahr2 = date.year
    end.submit
    tag_set = result_page.parser().xpath("//h2[contains(.,'Historische Kursdaten')]/../following-sibling::div//tr[2]/td")
    if tag_set == nil || tag_set.size() != 5
      raise DataMiningError, "Could not get a index value for the given date (#{date})", caller
    end
    LOG.debug("#{self.class}: Found historical index value for date #{tag_set[0].content()}")  
    LOG.debug("#{self.class}: Opening value #{tag_set[1].content()}")
    LOG.debug("#{self.class}: Closing value #{tag_set[2].content()}")
    opening = Util.l10n_f_k(tag_set[1].content().strip())
    closing = Util.l10n_f_k(tag_set[2].content().strip())
    return [opening, closing]
  end 

  # Extract all release dates of quarterly figures as a list
  def get_release_dates(quarterly_figure_dates)
    appointment_page = open_sub_page('Termine', 3, 2)
    tag_set = appointment_page.parser().xpath("//h2[contains(.,'vergangene Termine')]/../following-sibling::div//tr")
    if tag_set == nil || tag_set.size() < 2
      raise DataMiningError, "Could no extract release of quarterly figures", caller
      return
    end
    tag_set.each do |tr|
      td_list = tr.xpath('.//td')
      if td_list.size == 4
        if td_list[0].content() == 'Quartalszahlen'
          quartal = td_list[1].content()
          raw_date = td_list[2].content().strip
          date = Util.add_millennium(raw_date)
          quarterly_figure_dates << Util.to_t(date)
        elsif td_list[0].content() == 'Jahresabschluss'
          raw_date = td_list[2].content().strip
          date = Util.add_millennium(raw_date)
          quarterly_figure_dates << Util.to_t(date)
        end
      end
    end
  end

  public

  # Extract the reaction on the release of quarterly figures
  def extract_reaction_on_figures(reaction)
    quarterly_figure_dates = Array.new
    get_release_dates(quarterly_figure_dates)
    if quarterly_figure_dates.empty?
      raise DataMiningError, "Could no extract release of quarterly figures", caller
      return
    end
    LOG.debug("Latest release date for quarterly figures: #{Util.format(quarterly_figure_dates.sort.last)}")
    diff = Time.now - quarterly_figure_dates.sort.last 
    if diff < 0 || diff > THREE_MONTHS_IN_SECONDS
      raise DataMiningError, "Could no extract release of quarterly figures (date too old or in future)", caller
    end
    reaction.release_date = quarterly_figure_dates.sort.last
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

  def extract_insider_deals(results)
    insider_trades = open_sub_page('Insidertrades', 1, 0, @stock_page)
    rows = insider_trades.parser().xpath("//h1[contains(.,'Insidertrades bei ')]/../../div[@class='content']/table//tr[position() > 1]")
    LOG.debug("found #{rows.size} insider deals")
    share = Share.where(:isin => @share.isin).first
    rows.each do |row|
      cells = row.xpath('.//td')
      if cells.size == 6
        deal = InsiderDeal.new
        deal.share = share
        d = cells[0].content()
        full_date = Util.add_millenium(d)
        real_date = Util.to_t(full_date)
        deal.occurred = real_date
        deal.person = cells[1].content()
        deal.quantity = cells[2].content().sub(/\./, '')
        deal.price =Util.l10n_f(cells[3].content())
        action = cells[4].content()
        if action == 'Kauf'
          deal.trade_type = Transaction::BUY
        elsif action == 'Verkauf'
           deal.trade_type = Transaction::SELL
         else
           deal.trade_type = Transaction::UNKNOWN
        end
        details = cells[5].xpath("a").first.attr('href')
        deal.link = "#{FINANZEN_URL}#{details[1,details.length-1]}"
        
        results << deal
        exp = Util.information_expired(real_date, Util::DAY_IN_SECONDS * 92)
        if !exp
          LOG.debug("Datum: #{d}  Meldender: #{deal.person}  Anzahl: #{deal.quantity}  Kurs: #{deal.price}  Art: #{action}")
          duplicates = InsiderDeal.where(:share_id => share.id, :occurred => deal.occurred, :person => deal.person, :quantity => deal.quantity, :trade_type => deal.trade_type)
          if duplicates.size == 0
            deal.save!
          end
        end
      end
    end
  end

  # Extract the opinion of the analysts (Analystenmeinungen)
  def extract_analysts_opinion(analysts_opinion)
    page = open_sub_page("Kursziele", 1, 0, @stock_page)
    tr_set = page.parser().xpath('(//table)[3]//tr[position()>1]')
    if tr_set == nil || tr_set.size() < 1
      raise DataMiningError, "Could not extract analysts opinion", caller
    else
      LOG.debug("#{tr_set.size} analysts rated this stock")
      valid_ratings = Array.new
      tr_set.each do |tr|
        # Data extraction
        td_set = tr.xpath("child::node()")
        analyst = td_set[0].text()
        estimated_value = td_set[4].text()
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
          #LOG.debug("Expired: #{estimated_value} (released: #{Util.format(release_date)}) Analyst: #{analyst}")
        else
          if estimated_value == "-"
            #LOG.debug("No price for: #{estimated_value} (released: #{Util.format(release_date)}) Analyst: #{analyst}")
          else
            LOG.debug("#{estimated_value} (released: #{Util.format(release_date)}) Analyst: #{analyst}")
            valid_ratings << Util.l10n_f(estimated_value.sub(/€/, ''))
          end
        end
      end
      
      avg = 0
      valid_ratings.each do |rating|
        avg += rating
      end
      LOG.debug("\nAverage value: #{avg / valid_ratings.size}\n")
      
      #TODO
      analysts_opinion.buy = 0
      analysts_opinion.hold = 0
      analysts_opinion.sell = 0
      LOG.debug("#{self.class}: analyst opinion buy: #{analysts_opinion.buy}")
      LOG.debug("#{self.class}: analyst opinion hold: #{analysts_opinion.hold}")
      LOG.debug("#{self.class}: analyst opinion sell: #{analysts_opinion.sell}") 
    end
  end

end