require 'test_helper'
require 'engine/rating_unit'

class EquityRatioTest < ActiveSupport::TestCase
  test "positive rating" do
    rating = RatingUnit.rate_equity_ratio(equity_ratios(:positive))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_equity_ratio(equity_ratios(:neutral))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_equity_ratio(equity_ratios(:negative))
    assert rating == -1
  end
end
