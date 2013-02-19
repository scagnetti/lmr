require 'date'

# Provides static support methods
class Util
  
  DAY_IN_SECONDS = 60 * 60 * 24
  
  # Convert a decimal separator from comma (,) to dot (.)
  def Util.l10n_f(s)
    return s.sub(/,/, '.').to_f
  end
  
  # Convert a string to a float like 7.108,27 -> 7108.27
  # by eliminating the kilo separator and replacing the decimal separator.
  def Util.l10n_f_k(value)
    # Eliminate the dot
    t1 = value.sub(/\./, '')
    # Replace the comma with a dot
    t2 = t1.sub(/,/, '.')
    return t2.to_f
  end
  
  # Convert a given date pattern like 28.01.1948 (dd.MM.yyyy) into a time object.
  def Util.to_t(date)
    match = date.match(/^(\d{2})\.(\d{2})\.(\d{4})$/)
    if match == nil || match.size != 4
      return Time.at(0)
    else
      # Skipp leading zeros
      #year = match[3].to_i
      #month = match[2].sub(/^0/,'').to_i
      #day = match[1].sub(/^0/,'').to_i
      #time = Time.local(year, month, day)
      return Time.utc($3, $2, $1)
    end
  end
  
  # Checks if a given information is older than a certain threshold (in seconds).
  def Util.information_expired(date, threshold)
    raise "Couldn't validate age of information because the given date is nil" if date.nil?
    # The newer the information the smaller the difference in time up to now
    diff = Time.now - date
    if diff < threshold
      return false
    else
      return true
    end
  end

  # Apply default date format
  def Util.format(date)
    if date.nil?
      return "--"
    else
      return date.strftime("%Y.%m.%d")
    end
  end
  
  # Apply default date time format
  def Util.format_date_time(date)
    if date.nil?
      return "--"
    else
      return date.strftime("%Y.%m.%d - %H:%M:%S")
    end
  end

  # Ensures that the year part of a date consists
  # of four digits: dd.MM.yy -> dd.MM.yyyy
  def Util.add_millenium(date)
    date.sub(/(\d{2})$/, '20\1')
  end
  
  # A supplied time object is converted into a plain string
  def Util.ensure_string(time)
    if time.kind_of? Time
      return time.strftime('%d.%m.%Y')
    elsif time.kind_of? Date
      return time.strftime('%d.%m.%Y')
    else
      return time  
    end
  end
  
  # Crops the millennium part of a date
  # eg. 27.04.2012 -> 27.04.12
  def Util.crop_millennium(date)
    if date.kind_of? Time
      return date.strftime('%d.%m.%y')
    else
      return date.sub(/\d{2}(\d{2})$/, '\1')
    end
  end

  # Add the millennium part of a date
  # eg. 27.04.12 -> 27.04.2012
  def Util.add_millennium(date)
    if date =~ /\d{2}.\d{2}.\d{2}/
      return date.sub(/(\d{2})$/,"20\\1")
    else
      
    end
  end

  # Calculates the performance between two values in percent 
  # t2: value at the newer date
  # t1: value at the older date
  def Util.perf(t2, t1)
    ratio = ((t2 / t1) - 1) * 100
    return ratio.round(3)
  end
  
  # Calculates a date in the past by subtracting a certain amount of days from a given date
  # * +days+ - number of days to go back on time
  # * +date+ - the start date for the calculation
  def Util.step_back_in_time(days, date)
    history_date = date - DAY_IN_SECONDS * days
    # Handle weekends
    if history_date.wday == 0
      # Add one day to turn Sunday into a Monday
      history_date = history_date + DAY_IN_SECONDS
    elsif history_date.wday == 6
       # Subtract one day to turn Saturday into a Friday
       history_date = history_date - DAY_IN_SECONDS
    end
    return history_date 
  end
  
  # Subtract a given number of months from a given date.
  # * +date+ - the date where the months should be subtracted from 
  # * +amount+ - the number of months that should be subtracted 
  def Util.subtract_months_from(date, amount)
    y = date.year
    m = date.month
    check_result = date.month - amount
    if check_result == 0
      m = 12
      y = y - 1
    elsif check_result < 0
      m = check_result % 12
      y = y - 1
    end
    historical_date = Date.new(y,m,-1)
    return Util.avoid_weekend(historical_date)
  end
  
  # Checks if a date is a sunday or saturday.
  # If so the friday before the weekend is returned
  def Util.avoid_weekend(date)
    y = date.year
    m = date.month
    d = date.day
    # Check day in week
    if date.wday == 0
      d = d - 2
    elsif date.wday == 6
      d = d - 1
    end
    return Date.new(y,m,d)
  end
  
  # Checks if the stock exchange has closed at a given date.
  # If so a day before that public holiday is returned.
  def Util.avoid_exchange_closed(date)
        exchange_closed = [[1,1], [29,3],[1,4],[1,5],[24,12],[25,12],[26,12]]
    y = date.year
    m = date.month
    d = date.day
    if exchange_closed.include? [d, m]
      case exchange_closed.index [d, m]
      when 0
        m = 12
        d = 31
        y = y - 1
      when 1
        m = 3
        d = 28
      when 2
        m = 3
        d = 31
      when 3
        m = 4
        d = 30
      when 4
        m = 12
        d = 23
      when 5
        m = 12
        d = 23
      when 6
        m = 12
        d = 23
      end
    end
    return Date.new(y,m,d)
  end
  
  # TODO we still need to handle public holiday
  def Util.last_work_day_before(date)
    case date.wday()
    when 0
      # It's a Sunday so return Friday
      date = date - DAY_IN_SECONDS * 2
    when 1
      # It's a Monday so return Friday
      date = date - DAY_IN_SECONDS * 3
    when 2
      # It's a Tuesday so return Monday
      date = date - DAY_IN_SECONDS
    when 3
      # It's a Wednesday so return Tuesday
      date = date - DAY_IN_SECONDS
    when 4
      # It's a Thursday so return Wednesday
      date = date - DAY_IN_SECONDS
    when 5
      # It's a Friday so return Thursday
      date = date - DAY_IN_SECONDS
    when 6
      # It's a Saturday so return Friday
      date = date - DAY_IN_SECONDS
    end
    return date
  end
  
  # Read ISIN - stock name pairs from several files (e.g. *.txt)
  def Util.read_files(file_pattern)
    isin_stock_name_pairs = Hash.new
    Dir.glob(file_pattern).each do |file|
      tmp_hash = read_isin_from_file(file)
      isin_stock_name_pairs.merge!(tmp_hash)
    end
    return isin_stock_name_pairs
  end
  
  # Reads ISIN - stock name pairs from a text file
  def Util.read_isin_from_file(file_name)
    isin_stock_hash = Hash.new
    File.open(file_name).each_line do |line|
      line.match(/(.{12})\s(.*)/)
      isin_stock_hash[$1] = $2
    end
    return isin_stock_hash
  end

  # Extract the 6 digits that represent the WKN
  def Util.isin_to_wkn(isin)
    return isin.slice(5..10)
  end
  
  # Streams some content to a file (Mechanize::Page.body)
  # If possible use Mechanize::Page.save_as(file_name)
  def Util.content_to_file(content, file_name)
    File.open(file_name, 'w') do |f|
      f.write(content.to_s)
    end
  end

end