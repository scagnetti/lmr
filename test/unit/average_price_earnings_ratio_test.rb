require 'test_helper'
require 'engine/rating_unit'

class AveragePriceEarningsRatioTest < ActiveSupport::TestCase
  test "positive rating" do
    rating = RatingUnit.rate_average_price_earnings_ratio(average_price_earnings_ratios(:positive))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_average_price_earnings_ratio(average_price_earnings_ratios(:neutral))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_average_price_earnings_ratio(average_price_earnings_ratios(:negative))
    assert rating == -1
  end
end
