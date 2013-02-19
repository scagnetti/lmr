require 'test_helper'
require 'engine/rating_unit'

class EbitMarginTest < ActiveSupport::TestCase
  test "positive rating" do
    rating = RatingUnit.rate_ebit_margin(ebit_margins(:positive))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_ebit_margin(ebit_margins(:neutral))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_ebit_margin(ebit_margins(:negative))
    assert rating == -1
  end
end
