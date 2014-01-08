require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

# ruby -I test test/unit/index_value_test.rb
class IndexValueTest < ActiveSupport::TestCase
  
  DOW_DATE = "16.12.2013"
  DOW_OPENING = 15759.6
  DOW_CLOSING = 15884.57
  
  DAX_COLA_DATE = "20.08.2013"
  DAX_COLA_OPENING = 8294.87
  DAX_COLA_CLOSING = 8300.03
  
  test "the stock value extraction at historical dates" do
    populate_test_db()
    
    s = Share.where("name like ?", 'Coca%').first
    e = OnVistaExtractor.new(s)
    open_closing = e.index_value_extractor.extract_index_value_on(DOW_DATE)
    assert(open_closing[0] == DOW_OPENING, "Extracted stock value (#{open_closing[0]}) doesn't match expected value (#{DOW_OPENING})")
    assert(open_closing[1] == DOW_CLOSING, "Extracted stock value (#{open_closing[1]}) doesn't match expected value (#{DOW_CLOSING})")
    
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    open_closing = e.index_value_extractor.extract_index_value_on(DAX_COLA_DATE)
    assert(open_closing[0] == DAX_COLA_OPENING, "Extracted stock value (#{open_closing[0]}) doesn't match expected value (#{DAX_COLA_OPENING})")
    assert(open_closing[1] == DAX_COLA_CLOSING, "Extracted stock value (#{open_closing[1]}) doesn't match expected value (#{DAX_COLA_CLOSING})")
  end
  
end