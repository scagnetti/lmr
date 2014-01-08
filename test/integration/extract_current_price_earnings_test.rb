require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_current_price_earnings_test.rb
class ExtractCurrentPriceEarningsTest < ActiveSupport::TestCase

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
  
  test "the current price earnings ratio calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      cper = CurrentPriceEarningsRatio.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_current_price_earnings_ratio(cper)
      rescue DataMiningError => e
        cper.succeeded = false
        cper.error_msg = "#{e.to_s}"
      end
      msg = cper.error_msg == nil ? "" : cper.error_msg
      assert(cper.succeeded, msg)
    }
  end

  test "the current price earnings ratio calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      cper = CurrentPriceEarningsRatio.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_current_price_earnings_ratio(cper)
      rescue DataMiningError => e
        cper.succeeded = false
        cper.error_msg = "#{e.to_s}"
      end
      msg = cper.error_msg == nil ? "" : cper.error_msg
      assert(cper.succeeded, msg)
    }
  end

end
