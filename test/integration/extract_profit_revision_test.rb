require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_profit_revision_test.rb
class ExtractProfitRevisionTest < ActiveSupport::TestCase

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
  
  test "the profit revision calculation on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      profit_revision = ProfitRevision.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_profit_revision(profit_revision)
      rescue DataMiningError => e
        profit_revision.succeeded = false
        profit_revision.error_msg = "#{e.to_s}"
      end
      msg = profit_revision.error_msg == nil ? "" : profit_revision.error_msg
      assert(profit_revision.succeeded, msg)
    }
  end

  test "the profit revision calculation on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      profit_revision = ProfitRevision.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_profit_revision(profit_revision)
      rescue DataMiningError => e
        profit_revision.succeeded = false
        profit_revision.error_msg = "#{e.to_s}"
      end
      msg = profit_revision.error_msg == nil ? "" : profit_revision.error_msg
      assert(profit_revision.succeeded, msg)
    }
  end
  
  # test "dummy" do
    # shares = Share.joins(:stock_index).where("stock_indices.isin" => "US2605661048")
    # Rails.logger.debug("Loaded #{shares.size()} shares")
    # errors = Hash.new
    # map = Hash.new
    # shares.each do |s|
      # Rails.logger.debug("Processing: #{s.to_s}")
      # profit_revision = ProfitRevision.new
      # begin
        # e = OnVistaExtractor.new(s)
        # pr = e.extract_profit_revision(profit_revision)
        # populate(pr, map)
      # rescue DataMiningError => e
        # profit_revision.succeeded = false
        # profit_revision.error_msg = "#{e.to_s}"
      # end
      # msg = profit_revision.error_msg == nil ? "" : profit_revision.error_msg
      # assert(profit_revision.succeeded, msg)
    # end
    # Rails.logger.debug(map.inspect)
  # end
# 
  # def populate(key, map)
    # if map.include?(key)
      # i = map[key]
      # i = i+1
      # map[key] = i
    # else
      # map[key] = 1
    # end
  # end
end
