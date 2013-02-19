require 'test_helper'
require 'engine/rating_unit'

class ProfitRevisionTest < ActiveSupport::TestCase
  test "positive rating" do
    rating = RatingUnit.rate_profit_revision(profit_revisions(:positive))
    assert rating == 1
  end

  test "neutral rating" do
    rating = RatingUnit.rate_profit_revision(profit_revisions(:neutral))
    assert rating == 0
  end

  test "negative rating" do
    rating = RatingUnit.rate_profit_revision(profit_revisions(:negative))
    assert rating == -1
  end
  
  test "all equal" do
    rating = RatingUnit.rate_profit_revision(profit_revisions(:all_equal))
    assert rating == 0
  end
  
  test "two equal down" do
    rating = RatingUnit.rate_profit_revision(profit_revisions(:two_equal_down))
    assert rating == -1
  end

  test "two equal equal" do
    rating = RatingUnit.rate_profit_revision(profit_revisions(:two_equal_equal))
    assert rating == 0
  end
end
