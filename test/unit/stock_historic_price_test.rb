require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'

class StockValueTest < ActiveSupport::TestCase
  
  VW_DATE = "16.12.2013"
  VW_OPENING = 190
  VW_CLOSING = 192.6
  
  COCA_COLA_DATE = "20.08.2013"
  COCA_COLA_OPENING = 38.85
  COCA_COLA_CLOSING = 38.65
  
  test "the stock value extraction at historical dates" do
    populate_test_db()
    
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    open_closing = e.stock_value_extractor.extract_stock_value_on(VW_DATE)
    assert(open_closing[0] == VW_OPENING, "Extracted stock value (#{open_closing[0]}) doesn't match expected value (#{VW_OPENING})")
    assert(open_closing[1] == VW_CLOSING, "Extracted stock value (#{open_closing[1]}) doesn't match expected value (#{VW_CLOSING})")
    
    s = Share.where("name like ?", 'Coca%').first
    e = OnVistaExtractor.new(s)
    open_closing = e.stock_value_extractor.extract_stock_value_on(COCA_COLA_DATE)
    assert(open_closing[0] == COCA_COLA_OPENING, "Extracted stock value (#{open_closing[0]}) doesn't match expected value (#{COCA_COLA_OPENING})")
    assert(open_closing[1] == COCA_COLA_CLOSING, "Extracted stock value (#{open_closing[1]}) doesn't match expected value (#{COCA_COLA_CLOSING})")
  end
  
end