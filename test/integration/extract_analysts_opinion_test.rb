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
  
  test "the opinion of the analsysts on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      ao = AnalystsOpinion.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_analysts_opinion(ao)
      rescue DataMiningError => e
        ao.succeeded = false
        ao.error_msg = "#{e.to_s}"
      end
      msg = ao.error_msg == nil ? "" : ao.error_msg
      assert(ao.succeeded, msg)
    }
  end

  test "the opinion of the analsysts on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      ao = AnalystsOpinion.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_analysts_opinion(ao)
      rescue DataMiningError => e
        ao.succeeded = false
        ao.error_msg = "#{e.to_s}"
      end
      msg = ao.error_msg == nil ? "" : ao.error_msg
      assert(ao.succeeded, msg)
    }
  end

end
