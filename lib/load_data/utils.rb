module Utils

  MONTHS = {
    "Jan" => 1,
    "Feb" => 2,
    "Mar" => 3,
    "Apr" => 4,
    "May" => 5,
    "Jun" => 6,
    "Jul" => 7,
    "Aug" => 8,
    "Sep" => 9,
    "Oct" => 10,
    "Nov" => 11,
    "Dec" => 12
  }

  # 2011-11-29
  def Utils.build_date4(str)
    array = str.split('-')
    yr = array[0].to_i
    mo = array[1].to_i
    day = array[2].to_i
    Date.civil(yr,mo,day)
  end

  # 12/20/2010
  def Utils.build_date3(str)
    array = str.split("/")
    yr = array[2].to_i
    mo = array[0].to_i
    day = array[1].to_i
    Date.civil(yr,mo,day)
  end

  def Utils.build_date2(str)
    array = str.split(/\s+/)
    yr = array[2].to_i
    mo = MONTHS[array[1]]
    d = array[0].to_i
    Date.civil(yr,mo,d)
  end

# Oct 20, 2011 or October 20, 2011
  def Utils.build_date(str)
    yr = year(str)
    mo = MONTHS[str[0..2]] #already an integer
    d = day(str)
    begin
      Date.civil(yr.to_i,mo,d.to_i)
    rescue => e
      puts "invalid date for  #{str}"
      return nil
    end
  end

  def Utils.day(str)
    str =~ /\s(\d+),/
    $1
  end

  def Utils.year(str)
    str =~ /(\d\d\d\d)/
    $1
  end

  # takes an array of objects
  # concatenates their .to_s
  # makes a hex digest of the result
  def Utils.unique_key(hash)
    str = hash.values.each_with_object(""){ |elt, s| s << elt.to_s }
    Digest::MD5.hexdigest(str)
  end

end
