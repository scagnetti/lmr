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
    puts "Testing DAX shares"
    c = 0
    exec_on_index_shares("DE0008469008"){|s|
      extraction_test(s, c)
    }
    puts "EBIT extraction faild for #{c} shares"
    assert(true)
  end

  test "the EBIT calculation on DOW shares" do
    puts "Testing DOW shares"
    c = 0
    exec_on_index_shares("US2605661048"){|s|
      extraction_test(s, c)
    }
    puts "EBIT extraction faild for #{c} shares"
    assert(true)
  end

def extraction_test(share, counter)
    ebit = EbitMargin.new
    begin
      e = OnVistaExtractor.new(share)  
      e.extract_ebit_margin(ebit, share.financial)
      print "."
      $stdout.flush
    rescue DataMiningError => e
      print "E"
      $stdout.flush
      ebit.succeeded = false
      ebit.error_msg = "#{e.to_s}"
      puts "#{share.name} failed with this error message: \n#{ebit.error_msg}"
      counter = counter + 1
    end
  end

end
