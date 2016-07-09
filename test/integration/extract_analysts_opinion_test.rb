require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_analysts_opinion_test.rb
class ExtractAnalystsOpinionTest < ActiveSupport::TestCase
  
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
    puts "shares: #{Share.all.size}"
    share = Share.where("name LIKE ?", 'Adidas').first
    #share.public_methods.sort.each{|e| puts e}
    ao = AnalystsOpinion.new
    e = OnVistaExtractor.new(share)
    e.extract_analysts_opinion(ao)
    puts "buy: #{ao.buy}"
    puts "buy: #{ao.hold}"
    puts "buy: #{ao.sell}"
    assert(ao.buy >= 0, "Numeric value for analyst opinion buy is not valid")
    assert(ao.hold >= 0, "Numeric value for analyst opinion hold is not valid")
    assert(ao.sell >= 0, "Numeric value for analyst opinion sell is not valid")
  end

  test "the opinion of the analysts on DAX shares" do
    puts "Testing DAX shares"
    c = 0
    exec_on_index_shares("DE0008469008"){|s|
      extraction_test(s, c)
    }
    puts "Analysts Opinion extraction faild for #{c} shares"
    assert(true)
  end

  test "the opinion of the analysts on DOW shares" do
    puts "Testing DOW shares"
    c = 0
    exec_on_index_shares("US2605661048"){|s|
      extraction_test(s, c)
    }
    puts "Analysts Opinion extraction faild for #{c} shares"
    assert(true)
  end

  def extraction_test(share, counter)
    ao = AnalystsOpinion.new
    begin
      e = OnVistaExtractor.new(share)
      e.extract_analysts_opinion(ao)
      print "."
      $stdout.flush
    rescue RuntimeError => e
      print "E"
      $stdout.flush
      ao.succeeded = false
      ao.error_msg = "#{e.to_s}"
      puts "#{share.name} failed with this error message: \n#{ao.error_msg}"
      counter = counter + 1
    end
  end

end
