require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_equity_ratio_test.rb
class ExtractEquityRatioTest < ActiveSupport::TestCase

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
  
  test "the equity ratio calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      er = EquityRatio.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_equity_ratio(er)
      rescue DataMiningError => e
        er.succeeded = false
        er.error_msg = "#{e.to_s}"
      end
      msg = er.error_msg == nil ? "" : er.error_msg
      assert(er.succeeded, msg)
    }
  end

  test "the equity ratio calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      er = EquityRatio.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_equity_ratio(er)
      rescue DataMiningError => e
        er.succeeded = false
        er.error_msg = "#{e.to_s}"
      end
      msg = er.error_msg == nil ? "" : er.error_msg
      assert(er.succeeded, msg)
    }
  end

end
