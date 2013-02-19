require 'test_helper'
require 'engine/rating_unit'

class StockPriceDevTest < ActiveSupport::TestCase
  test "positive rating" do
    rating = RatingUnit.rate_half_year_stock_price_dev(stock_price_devs(:positive))
    assert rating == 1
    rating = RatingUnit.rate_one_year_stock_price_dev(stock_price_devs(:positive))
    assert rating == 1
    rating = RatingUnit.rate_stock_price_momentum(stock_price_devs(:down_up))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_half_year_stock_price_dev(stock_price_devs(:neutral))
    assert rating == 0
    rating = RatingUnit.rate_one_year_stock_price_dev(stock_price_devs(:neutral))
    assert rating == 0
    rating = RatingUnit.rate_stock_price_momentum(stock_price_devs(:up_up))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_half_year_stock_price_dev(stock_price_devs(:negative))
    assert rating == -1
    rating = RatingUnit.rate_one_year_stock_price_dev(stock_price_devs(:negative))
    assert rating == -1
    rating = RatingUnit.rate_stock_price_momentum(stock_price_devs(:up_down))
    assert rating == -1
  end
end
