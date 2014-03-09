require 'test_helper'
require 'engine/extractor/on_vista_extractor.rb'
require 'engine/types/asset_value.rb'

# ruby -I test test/unit/stock_historic_price_test.rb
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
    asset_value = e.stock_value_extractor.extract_stock_value_on(VW_DATE)
    assert(asset_value.opening() == VW_OPENING, "Extracted stock value (#{asset_value.opening()}) doesn't match expected value (#{VW_OPENING})")
    assert(asset_value.closing() == VW_CLOSING, "Extracted stock value (#{asset_value.closing()}) doesn't match expected value (#{VW_CLOSING})")
    
    s = Share.where("name like ?", 'Coca%').first
    e = OnVistaExtractor.new(s)
    asset_value = e.stock_value_extractor.extract_stock_value_on(COCA_COLA_DATE)
    assert(asset_value.opening() == COCA_COLA_OPENING, "Extracted stock value (#{asset_value.opening()}) doesn't match expected value (#{COCA_COLA_OPENING})")
    assert(asset_value.closing() == COCA_COLA_CLOSING, "Extracted stock value (#{asset_value.closing()}) doesn't match expected value (#{COCA_COLA_CLOSING})")
  end
  
end