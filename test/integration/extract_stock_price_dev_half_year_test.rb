require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_stock_price_dev_half_year_test.rb
class ExtractStockPriceDevHalfYearTest < ActiveSupport::TestCase

  # called before every single test
  def setup
    puts "Setup running..."
    %x[rake db:data:load]
  end
 
  # called after every single test
  def teardown
    puts "Teardown running..."
    %x[rake db:reset]
  end
  
  test "the stock price dev half year calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      figure = StockPriceDevHalfYear.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_stock_price_dev_half_year(figure)
      rescue DataMiningError => e
        figure.succeeded = false
        figure.error_msg = "#{e.to_s}"
      end
      msg = figure.error_msg == nil ? "" : figure.error_msg
      assert(figure.succeeded, msg)
    }
  end

  test "the stock price dev half year calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      figure = StockPriceDevHalfYear.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_stock_price_dev_half_year(figure)
      rescue DataMiningError => e
        figure.succeeded = false
        figure.error_msg = "#{e.to_s}"
      end
      msg = figure.error_msg == nil ? "" : figure.error_msg
      assert(figure.succeeded, msg)
    }
  end

end
