require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_roe_test.rb
class ExtractRoeTest < ActiveSupport::TestCase

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
  
  test "the ROE calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      roe = ReturnOnEquity.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_roe(roe)
      rescue DataMiningError => e
        roe.succeeded = false
        roe.error_msg = "#{e.to_s}"
      end
      msg = roe.error_msg == nil ? "" : roe.error_msg
      assert(roe.succeeded, msg)
    }
  end

  test "the ROE calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      roe = ReturnOnEquity.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_roe(roe)
      rescue DataMiningError => e
        roe.succeeded = false
        roe.error_msg = "#{e.to_s}"
      end
      msg = roe.error_msg == nil ? "" : roe.error_msg
      assert(roe.succeeded, msg)
    }
  end

end
