require 'engine/rating/large_cap_rating_unit.rb'
require 'engine/rating/small_cap_rating_unit.rb'
require 'engine/rating/large_cap_financial_rating_unit.rb'
require 'engine/rating/small_cap_financial_rating_unit.rb'

# Depending on the given stock we distinguish between large and small caps
# and if it is a financial company or not. There is a special rating unit
# for each combination. 
class RatingService
  
  # Initialize all available rating units
  def initialize
    @large = LargeCapRatingUnit.new
    @small = SmallCapRatingUnit.new
    @large_fin = LargeCapFinancialRatingUnit.new
    @small_fin = SmallCapFinancialRatingUnit.new
  end
  
  # Provides the matching rating unit regarding the
  # size and the financial character of a company.
  # * +size+ - the company size
  # * +financial+ - the type of the company
  def choose_rating_unit(size, financial)
    if size == CompanySize::LARGE && financial == false
      return @large
    elsif size == CompanySize::LARGE && financial == true
      return @large_fin
    elsif size == CompanySize::SMALL && financial == false
      return @small
    elsif size == CompanySize::MID && financial == false
      return @small
    elsif size == CompanySize::SMALL && financial == true
      return @small_fin
    elsif size == CompanySize::MID && financial == true
      return @small_fin
    else
      raise RuntimError, "Could not find appropriate rating unit for size value: #{size} and financial value: #{financial}", caller
    end
  end
end