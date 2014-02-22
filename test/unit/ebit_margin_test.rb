require 'test_helper'
require 'engine/rating/rating_service.rb'

# Test all possible rating scenarios. 
# For financial companies this figure is alwasy rated with 0
# ruby -I test test/unit/ebit_margin_test.rb
class EbitMarginTest < ActiveSupport::TestCase
  #=================
  #=Large companies=
  #=================
  test "large cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_ebit_margin(ebit_margins(:positive))
    assert rating == 1
  end
  
  test "large cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_ebit_margin(ebit_margins(:neutral))
    assert rating == 0
  end
  
  test "large cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_ebit_margin(ebit_margins(:negative))
    assert rating == -1
  end

  #===========================
  #=Large financial companies=
  #===========================
  test "large financial cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_ebit_margin(ebit_margins(:positive))
    assert rating == 0
  end
  
  test "large financial cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_ebit_margin(ebit_margins(:neutral))
    assert rating == 0
  end
  
  test "large financial cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_ebit_margin(ebit_margins(:negative))
    assert rating == 0
  end
  
  #=================
  #=Small companies=
  #=================
  test "small cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_ebit_margin(ebit_margins(:positive))
    assert rating == 1
  end
  
  test "small cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_ebit_margin(ebit_margins(:neutral))
    assert rating == 0
  end
  
  test "small cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_ebit_margin(ebit_margins(:negative))
    assert rating == -1
  end

  #===========================
  #=Small financial companies=
  #===========================
  test "small financial cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_ebit_margin(ebit_margins(:positive))
    assert rating == 0
  end
  
  test "small financial cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_ebit_margin(ebit_margins(:neutral))
    assert rating == 0
  end
  
  test "small financial cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_ebit_margin(ebit_margins(:negative))
    assert rating == 0
  end

end
