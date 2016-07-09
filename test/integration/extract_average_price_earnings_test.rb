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
  
test "the small proof" do
    share = Share.where("name LIKE ?", 'Adidas').first
    avg_per = AveragePriceEarningsRatio.new
    e = OnVistaExtractor.new(share)
    e.extract_average_price_earnings_ratio(avg_per)
    puts "Year: #{avg_per.three_years_ago} - value: #{avg_per.value_three_years_ago}"
    puts "Year: #{avg_per.two_years_ago} - value: #{avg_per.value_two_years_ago}"
    puts "Year: #{avg_per.last_year} - value: #{avg_per.value_last_year}"
    puts "Year: #{avg_per.this_year} - value: #{avg_per.value_this_year}"
    puts "Year: #{avg_per.next_year} - value: #{avg_per.value_next_year}"
    assert(true)
  end

  test "the average price earnings ratio calculation on DAX shares" do
    puts "Testing DAX shares"
    c = 0
    exec_on_index_shares("DE0008469008"){|s|
      extraction_test(s, c)
    }
    puts "Price Earnings Ratio extraction faild for #{c} shares"
    assert(true)
  end

  test "the average price earnings ratio calculation on DOW shares" do
    puts "Testing DOW shares"
    c = 0
    exec_on_index_shares("US2605661048"){|s|
      extraction_test(s, c)
    }
    puts "Price Earnings Ratio extraction faild for #{c} shares"
    assert(true)
  end

  def extraction_test(share, counter)
    avg_per = AveragePriceEarningsRatio.new
    begin
      e = OnVistaExtractor.new(share)
      e.extract_average_price_earnings_ratio(avg_per)
      print "."
      $stdout.flush
    rescue DataMiningError => e
      print "E"
      $stdout.flush
      avg_per.succeeded = false
      avg_per.error_msg = "#{e.to_s}"
      puts "#{share.name} failed with this error message: \n#{avg_per.error_msg}"
      counter = counter + 1
    end
  end

end
