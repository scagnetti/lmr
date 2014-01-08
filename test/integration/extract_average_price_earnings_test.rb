require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_average_price_earnings_test.rb
class ExtractAveragePriceEarningsTest < ActiveSupport::TestCase

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
  
  test "the average price earnings ratio calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      avg_per = AveragePriceEarningsRatio.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_average_price_earnings_ratio(avg_per)
      rescue DataMiningError => e
        avg_per.succeeded = false
        avg_per.error_msg = "#{e.to_s}"
      end
      msg = avg_per.error_msg == nil ? "" : avg_per.error_msg
      assert(avg_per.succeeded, msg)
    }
  end

  test "the average price earnings ratio calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      avg_per = AveragePriceEarningsRatio.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_average_price_earnings_ratio(avg_per)
      rescue DataMiningError => e
        avg_per.succeeded = false
        avg_per.error_msg = "#{e.to_s}"
      end
      msg = avg_per.error_msg == nil ? "" : avg_per.error_msg
      assert(avg_per.succeeded, msg)
    }
  end

end
