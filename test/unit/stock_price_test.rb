require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/unit/stock_price_test.rb
class StockPriceTest < ActiveSupport::TestCase

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

  test "the dax stock price calculation" do
    exec_on_index_shares("DE0008469008"){|share|
      e = OnVistaExtractor.new(share)
      result = e.extract_stock_price()
      assert result['price'].to_s.match('\d+\.\d+') != nil
      assert result['currency'] == Currency::EUR
    }
  end

  test "the dow stock price calculation" do
    exec_on_index_shares("US2605661048"){|share|
      e = OnVistaExtractor.new(share)
      result = e.extract_stock_price()
      assert result['price'].to_s.match('\d+\.\d+') != nil
      assert result['currency'] == Currency::USD
    }
  end

end
