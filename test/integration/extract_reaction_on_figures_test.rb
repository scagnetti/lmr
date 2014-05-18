require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/integration/extract_reaction_on_figures_test.rb
class ExtractReactionOnFiguresTest < ActiveSupport::TestCase

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

  test "the reaction on figures on DAX shares" do
    exec_on_index_shares("DE0008469008"){|share|
      reaction = Reaction.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_reaction_on_figures(reaction)
        Rails.logger.debug("Release date: #{reaction.release_date}, index opening: #{reaction.index_opening}, index closing: #{reaction.index_closing}, share opening: #{reaction.price_opening}, share closing: #{reaction.price_closing}")
      rescue DataMiningError => e
        reaction.succeeded = false
        reaction.error_msg = "#{e.to_s}"
        errors[s.isin] = e.to_s
      end
      msg = reaction.error_msg == nil ? "" : reaction.error_msg
      assert(reaction.succeeded, msg)
    }
  end

  # Some shares are not available in the NYSE stock exchange:
  # Intel (US4581401001)
  # Cisco-Systems (US17275R1023)
  test "the reaction on figures on DOW shares" do
    exec_on_index_shares("US2605661048"){|share|
      reaction = Reaction.new
      begin
        e = OnVistaExtractor.new(share)
        e.extract_reaction_on_figures(reaction)
        Rails.logger.debug("Release date: #{reaction.release_date}, index opening: #{reaction.index_opening}, index closing: #{reaction.index_closing}, share opening: #{reaction.price_opening}, share closing: #{reaction.price_closing}")
      rescue DataMiningError => e
        reaction.succeeded = false
        reaction.error_msg = "#{e.to_s}"
        errors[s.isin] = e.to_s
      end
      msg = reaction.error_msg == nil ? "" : reaction.error_msg
      assert(reaction.succeeded, msg)
    }
  end

end
