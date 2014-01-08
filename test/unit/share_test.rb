require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  test "print attributes" do
    adidas = shares(:adidas)
    puts "Size: #{adidas.size}"
    puts "Stock Exchange: #{adidas.stock_exchange}"
    puts "Currency: #{adidas.currency}"
    puts "Stock Index: #{adidas.stock_index.name}"
    assert adidas.name == 'Adidas'
  end
end
