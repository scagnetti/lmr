require 'test_helper'
require 'engine/rating/rating_service.rb'

# Test all possible rating scenarios. 
# There is only one rule for all types of companies (small/large and financial)
# ruby -I test test/unit/profit_growth_test.rb
class ProfitGrowthTest < ActiveSupport::TestCase
  #=================
  #=Large companies=
  #=================
  test "large cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_profit_growth(profit_growths(:positive))
    assert rating == 1
  end
  
  test "large cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_profit_growth(profit_growths(:neutral))
    assert rating == 0
  end
  
  test "large cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, false).rate_profit_growth(profit_growths(:negative))
    assert rating == -1
  end

#===========================
  #=Large financial companies=
  #===========================
  test "large financial cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_profit_growth(profit_growths(:positive))
    assert rating == 1
  end
  
  test "large financial cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_profit_growth(profit_growths(:neutral))
    assert rating == 0
  end
  
  test "large financial cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::LARGE, true).rate_profit_growth(profit_growths(:negative))
    assert rating == -1
  end
  
  #=================
  #=Small companies=
  #=================
  test "small cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_profit_growth(profit_growths(:positive))
    assert rating == 1
  end
  
  test "small cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_profit_growth(profit_growths(:neutral))
    assert rating == 0
  end
  
  test "small cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, false).rate_profit_growth(profit_growths(:negative))
    assert rating == -1
  end

  #===========================
  #=Small financial companies=
  #===========================
  test "small financial cap positive" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_profit_growth(profit_growths(:positive))
    assert rating == 1
  end
  
  test "small financial cap neutral" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_profit_growth(profit_growths(:neutral))
    assert rating == 0
  end
  
  test "small financial cap negative" do
    rating = RatingService.new.choose_rating_unit(CompanySize::SMALL, true).rate_profit_growth(profit_growths(:negative))
    assert rating == -1
  end
end
