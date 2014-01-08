require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_profit_growth_test.rb
class ExtractProfitGrowthTest < ActiveSupport::TestCase

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
  
  test "the profit growth on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      profit_growth = ProfitGrowth.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_profit_growth(profit_growth)
      rescue DataMiningError => e
        profit_growth.succeeded = false
        profit_growth.error_msg = "#{e.to_s}"
      end
      msg = profit_growth.error_msg == nil ? "" : profit_growth.error_msg
      assert(profit_growth.succeeded, msg)
    }
  end

  test "the profit growth on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      profit_growth = ProfitGrowth.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_profit_growth(profit_growth)
      rescue DataMiningError => e
        profit_growth.succeeded = false
        profit_growth.error_msg = "#{e.to_s}"
      end
      msg = profit_growth.error_msg == nil ? "" : profit_growth.error_msg
      assert(profit_growth.succeeded, msg)
    }
  end

end
