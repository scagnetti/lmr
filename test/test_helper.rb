# rake test: runs all unit, functional and integration tests.
# rake test:units: runs all the unit tests.
# rake test:functionals: runs all the functional tests.
# rake test:integration: runs all the integration tests.

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  # Add more helper methods to be used by all tests here...
  def run_on_dax_shares()
    isin_dax = 'DE0008469008'
    @agent = Mechanize.new
    @page = @agent.get('http://www.finanzen.net/index/DAX')
    tag_set = @page.parser().xpath("(//h2[.='DAX 30'])[1]/../following-sibling::div/table/tr[position()>1]")
    tag_set.each do |tr|
      td_set = tr.xpath("child::node()")
      content = td_set[0].text()
      isin = content[-12,12]
      puts "\nTesting stock with ISIN: #{isin}"
      # Call the given block with the current stock ISIN and index ISIN
      yield(isin, isin_dax)
    end
  end

  def run_on_dow_shares()
    isin_dow = 'US2605661048'
    @agent = Mechanize.new
    @page = @agent.get('http://www.finanzen.net/index/Dow_Jones')
    tag_set = @page.parser().xpath("(//h2[.='Dow Jones 30 Industrial'])[1]/../following-sibling::div/table/tr[position()>1]")
    tag_set.each do |tr|
      td_set = tr.xpath("child::node()")
      content = td_set[0].text()
      isin = content[-12,12]
      puts "\nTesting stock with ISIN: #{isin}"
      # Call the given block with the current stock ISIN and index ISIN
      yield(isin, isin_dow)
    end
  end

  def populate_test_db()
    %x[rake db:data:load]
  end
  
  # Execute a given block on each share of an index
  # * +index_isin+ - load the shares of this index
  def exec_on_index_shares(index_isin)
    shares = Share.joins(:stock_index).where("stock_indices.isin" => index_isin)
    Rails.logger.debug("Loaded #{shares.size()} shares")
    errors = Hash.new
    shares.each do |s|
      Rails.logger.debug("Processing: #{s.to_s}")
      yield(s)
    end
  end
end
