# Describes the opening and closign value of an asset
# (e.g. a share or an index) traded at a stock exchange
class AssetValue

 attr_accessor :representing_date, :opening, :closing

  # The constructor that expects a date which represents
  # the validity of opening and closing values 
  # * +date+ - the representing date
  def initialize(date)
    @representing_date = date
  end

end