require 'test_helper'
require 'engine/rating/rating_service.rb'

# Test all possible rating scenarios. 
# Large caps are rated with -1 if the mayority of analysts say buy
# Large caps are rated with 0 if the mayority of analysts say hold
# Large caps are rated with +1 if the mayority of analysts say sell
# Small and Mid caps are rated differently depending on the number of watching analysts.
# If there are more than 5 analysts watching it goes the same as for large caps
# If there are less than 5 analysts watching the rating is inverted
# ruby -I test test/unit/analysts_opinion_test.rb
class AnalystsOpinionTest < ActiveSupport::TestCase
  #=================
  #=Large companies=
  #=================
  test "large cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_analysts_opinion(analysts_opinions(:many_analysts_sell))
    assert rating == 1
  end
  
  test "large cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_analysts_opinion(analysts_opinions(:many_analysts_tie))
    assert rating == 0
  end
  
  test "large cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_analysts_opinion(analysts_opinions(:many_analysts_buy))
    assert rating == -1
  end

  #===========================
  #=Large financial companies=
  #===========================
  test "large financial cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_analysts_opinion(analysts_opinions(:many_analysts_sell))
    assert rating == 1
  end
  
  test "large financial cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_analysts_opinion(analysts_opinions(:many_analysts_tie))
    assert rating == 0
  end
  
  test "large financial cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_analysts_opinion(analysts_opinions(:many_analysts_buy))
    assert rating == -1
  end
  
  #===========================================
  #=Small companies with less than 5 analysts=
  #===========================================
  test "small cap less than five positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_analysts_opinion(analysts_opinions(:few_analysts_buy))
    assert rating == 1
  end
  
  test "small cap less than five neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_analysts_opinion(analysts_opinions(:few_analysts_tie))
    assert rating == 0
  end
  
  test "small cap less than five negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_analysts_opinion(analysts_opinions(:few_analysts_sell))
    assert rating == -1
  end
  
  #===========================================
  #=Small companies with more than 5 analysts=
  #===========================================
  test "small cap more than five positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_analysts_opinion(analysts_opinions(:many_analysts_sell))
    assert rating == 1
  end
  
  test "small cap more than five neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_analysts_opinion(analysts_opinions(:many_analysts_tie))
    assert rating == 0
  end
  
  test "small cap more than five negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_analysts_opinion(analysts_opinions(:many_analysts_buy))
    assert rating == -1
  end

  #=====================================================
  #=Small companies financial with less than 5 analysts=
  #=====================================================
  test "small cap financial less than five positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_analysts_opinion(analysts_opinions(:few_analysts_buy))
    assert rating == 1
  end
  
  test "small cap financial less than five neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_analysts_opinion(analysts_opinions(:few_analysts_tie))
    assert rating == 0
  end
  
  test "small cap financial less than five negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_analysts_opinion(analysts_opinions(:few_analysts_sell))
    assert rating == -1
  end
  
  #=====================================================
  #=Small companies financial with more than 5 analysts=
  #=====================================================
  test "small cap financial more than five positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_analysts_opinion(analysts_opinions(:many_analysts_sell))
    assert rating == 1
  end
  
  test "small cap financial more than five neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_analysts_opinion(analysts_opinions(:many_analysts_tie))
    assert rating == 0
  end
  
  test "small cap financial more than five negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_analysts_opinion(analysts_opinions(:many_analysts_buy))
    assert rating == -1
  end

end
