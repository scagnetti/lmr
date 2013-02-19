require 'test_helper'
require 'engine/rating_unit'

class ReturnOnEquityTest < ActiveSupport::TestCase

  test "positive rating" do
    rating = RatingUnit.rate_roe(return_on_equities(:positive))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_roe(return_on_equities(:neutral))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_roe(return_on_equities(:negative))
    assert rating == -1
  end
end
