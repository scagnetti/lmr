require 'test_helper'
require 'engine/rating_unit'

class ReactionTest < ActiveSupport::TestCase
  test "positive rating" do
    rating = RatingUnit.rate_reaction(reactions(:positive))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_reaction(reactions(:neutral))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_reaction(reactions(:negative))
    assert rating == -1
  end
end
