require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_ebit_test.rb
class ExtractEbitTest < ActiveSupport::TestCase

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
  
  test "the EBIT calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      ebit = EbitMargin.new
      begin
        e = OnVistaExtractor.new(share)  
        e.extract_ebit_margin(ebit, share.financial)
      rescue DataMiningError => e
        ebit.succeeded = false
        ebit.error_msg = "#{e.to_s}"
      end
      msg = ebit.error_msg == nil ? "" : ebit.error_msg
      assert(ebit.succeeded, msg)
    }
  end

  test "the EBIT calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      ebit = EbitMargin.new
      begin
        e = OnVistaExtractor.new(share)  
        e.extract_ebit_margin(ebit, share.financial)
      rescue DataMiningError => e
        ebit.succeeded = false
        ebit.error_msg = "#{e.to_s}"
      end
      msg = ebit.error_msg == nil ? "" : ebit.error_msg
      assert(ebit.succeeded, msg)
    }
  end

end
