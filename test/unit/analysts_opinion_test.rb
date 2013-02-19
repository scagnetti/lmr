require 'test_helper'
require 'engine/rating_unit'

class AnalystsOpinionTest < ActiveSupport::TestCase

  test "positive rating" do
    rating = RatingUnit.rate_analysts_opinion(analysts_opinions(:positive))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_analysts_opinion(analysts_opinions(:neutral))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_analysts_opinion(analysts_opinions(:negative))
    assert rating == -1
  end
end
