require 'test_helper'
require 'engine/rating/rating_service.rb'

# Test all possible rating scenarios.
# Large caps get a negative rating if the share performance tops the index performacne for three months.
# Large caps get a positive rating if the share performance drops the index performacne for three months.
# Small and mid caps are get always zero points! 
# ruby -I test test/unit/reversal_test.rb
class ReversalTest < ActiveSupport::TestCase
  #=================
  #=Large companies=
  #=================
  test "large cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_reversal(reversals(:positive))
    assert rating == 1
  end
  
  test "large cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_reversal(reversals(:neutral))
    assert rating == 0
  end
  
  test "large cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_reversal(reversals(:negative))
    assert rating == -1
  end

  #===========================
  #=Large financial companies=
  #===========================
  test "large financial cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_reversal(reversals(:positive))
    assert rating == 1
  end
  
  test "large financial cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_reversal(reversals(:neutral))
    assert rating == 0
  end
  
  test "large financial cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_reversal(reversals(:negative))
    assert rating == -1
  end
  
  #=================
  #=Small companies=
  #=================
  test "small cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_reversal(reversals(:positive))
    assert rating == 0
  end
  
  test "small cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_reversal(reversals(:neutral))
    assert rating == 0
  end
  
  test "small cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_reversal(reversals(:negative))
    assert rating == 0
  end

  #===========================
  #=Small financial companies=
  #===========================
  test "small financial cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_reversal(reversals(:positive))
    assert rating == 0
  end
  
  test "small financial cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_reversal(reversals(:neutral))
    assert rating == 0
  end
  
  test "small financial cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_reversal(reversals(:negative))
    assert rating == 0
  end
end
