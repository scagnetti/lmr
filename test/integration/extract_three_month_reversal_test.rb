require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_three_month_reversal_test.rb
class ExtractThreeMonthReversalTest < ActiveSupport::TestCase

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
  
  test "the three month reversal calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      reversal = Reversal.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_three_month_reversal(reversal)
      rescue DataMiningError => e
        reversal.succeeded = false
        reversal.error_msg = "#{e.to_s}"
      end
      msg = reversal.error_msg == nil ? "" : reversal.error_msg
      assert(reversal.succeeded, msg)
    }
  end

  test "the three month reversal calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      reversal = Reversal.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_three_month_reversal(reversal)
      rescue DataMiningError => e
        reversal.succeeded = false
        reversal.error_msg = "#{e.to_s}"
      end
      msg = reversal.error_msg == nil ? "" : reversal.error_msg
      assert(reversal.succeeded, msg)
    }
  end

end
