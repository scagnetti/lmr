# encoding: UTF-8
require 'engine/util'
require 'engine/extractor/basic_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/exceptions/invalid_isin_error.rb'

# This class has the capability to extract allor at least a part of the information neccessary to evaluate
# a stock against the rules defined by Susan Levermann from the Boerse web site.
class FinanzenExtractor < BasicExtractor

  FINANZEN_URL = "http://www.finanzen.net/"
  
  SEARCH_FAILURE = "//div[contains(.,'Keine Ergebnisse')]"
  THREE_MONTHS_IN_SECONDS = 60 * 60 * 24 * 31 * 3

  def initialize(stock_isin, index_isin)
    super(FINANZEN_URL)
    LOG.debug("#{self.class} initialized with stock: #{stock_isin} and index: #{index_isin}")
    @stock_page = perform_search("action", '/suchergebnis.asp', "frmAktiensucheTextfeld", stock_isin, SEARCH_FAILURE)
    @index_page = perform_search("action", '/suchergebnis.asp', "frmAktiensucheTextfeld", index_isin, SEARCH_FAILURE)
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
  def extract_reaction_on_figures(index_isin, reaction)
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

end