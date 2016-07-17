require 'rubygems'
require 'mechanize'
require 'watir'
require 'watir-webdriver'

# Manages the portfolio on boerse.ard.de
class BoerseArd
  URL = "http://boerse.ard.de"

  def initialize
    @browser = Watir::Browser.new
    @browser.goto(URL)
  end

  def login()
    @browser.link(:text => /Mein Depot/).click
    @browser.link(:text => /Passwort vergessen/).wait_until_present
    @browser.forms(:action, "http://kurse.boerse.ard.de/ard/anmeldung.htn")[1].text_field(:name => 'lg').set 'PeterBauer'
    @browser.forms(:action, "http://kurse.boerse.ard.de/ard/anmeldung.htn")[1].text_field(:name => 'pw').set '28148hk15699'
    @browser.forms(:action, "http://kurse.boerse.ard.de/ard/anmeldung.htn")[1].button(:value => 'Einloggen').click
    puts @browser.title
  end

  def logout()
    @browser.link(:text => /Mein Depot/).click
    @browser.link(:text => /Ausloggen/).wait_until_present
    @browser.link(:text => /Ausloggen/).click
  end

  def buy(isin, portfolio)
    puts "Buying stock #{isin}"

    @browser.link(:text => /Wertpapier kaufen/).wait_until_present
    @browser.link(:text => /Wertpapier kaufen/).click
    puts @browser.title

    @browser.text_field(:name => 'suchbegriff').wait_until_present
    @browser.text_fields(:name => 'suchbegriff')[1].set(isin)
    @browser.button(:text => 'Suchen').click

    @browser.form(:name, "wpkauf").select_list(:name => 'pId').select(portfolio)

    @browser.form(:name, "frmPortfolioWpBuy").text_field(:name => 'stueck').wait_until_present
    @browser.form(:name, "frmPortfolioWpBuy").text_field(:name => 'stueck').set(calculate_quantity())
    @browser.form(:name, "frmPortfolioWpBuy").text_field(:name => 'memo').set('Bought by Mr. Roboto')
    @browser.button(:value => 'Kaufen').click
 
    #@browser.screenshot.save 'current_portfolio.png'
  end

  def sell(isin, portfolio)
    puts "Selling stock #{isin}"
    xpath = "//td[text() = '#{isin}']/../preceding-sibling::tr/td/a"
    tag_set = @browser.links(:xpath => xpath)
    delete_link = tag_set.last()
    delete_link.click
    @browser.button(:value => 'Verkaufen').click
    @browser.button(:xpath => '//input[@value="Verkaufen"][@type="submit"]').click
    @browser.link(:text => 'Überblick').click
    @browser.link(text: 'Erweitert').wait_until_present
    @browser.link(text: 'Erweitert').click
    # Wait for portfolio loaded in detail view
    @browser.td(:text => /Barbestand/).wait_until_present
  end

  # Alle Aktien bzw. deren ISIN-Werte eines Depots auflisten
  def list(portfolio)
    @browser.select_list(:name => 'pId').select(portfolio)

    @browser.link(text: 'Erweitert').wait_until_present
    @browser.link(text: 'Erweitert').click
    # Wait for portfolio loaded in detail view
    @browser.td(:text => /Barbestand/).wait_until_present
    # Alternativer XPATH: $x("//td[@headers='isin'][text()='DE0005190003']")
    td_set = @browser.tds(headers: 'isin')

    return td_set.collect { |td| td.text() }
  end

  # Bei 4000 Euro liegt die Gebuehr bei 0,25%
  def calculate_quantity
    @browser.text_field(:name => 'kaufkurs').wait_until_present
    price = @browser.text_field(:name => 'kaufkurs').value.sub(".", "").sub(",", ".").to_f
    quantity = (4000 / price).to_i
    return quantity
  end

  # Feststellen ob eine Aktie bereits im Depot (engl. portfolio) ist
  def stock_in_prortfolio?(isin, portfolio)
    isin_list = list(portfolio)
    found = isin_list.include?(isin)
    puts "Does the portfolio #{portfolio} hold the share #{isin}? #{found}"
    return found
  end

end