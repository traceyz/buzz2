class Scraper < ActiveRecord::Base

  require 'open-uri'

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

  def Scraper.get_reviews(forum)
    klass = "#{forum.name}Review"
    forum.product_links.each do |product_link|
      product_link.link_urls.each do |link_url|
        url = forum.root + link_url.link + forum.tail
        doc = Nokogiri::HTML(open(url))
        reviews_from_page(doc,link_url,klass)
        onward_link = next_link(doc)
        puts onward_link ? onward_link : "NO NEXT LINK"
      end
    end
    nil
  end

  def Scraper.reviews_from_page(doc,link_url,klass)
    reviews = []
    review_class = Object.const_get(klass)
    page_reviews(doc).each do |review|
      key = get_unique_key(review)
      next unless key
      if review_class.where(:unique_key => key).first
        puts "Review already exists"; next
      end
      args = {:unique_key => key, :link_url_id => link_url.id}
      add_args = args_from_review(review)
      next unless add_args
      args.update(unescape(add_args))
      the_review = review_class.new(args)
      unless the_review.valid?
        puts "INVALID"
        puts the_review.inspect
        next
      end
      the_review.save!
      reviews << the_review
    end
    reviews
  end

  def Scraper.unescape(args)
    [:headline, :body, :author, :location].each do |k|
      args[k] = CGI.unescapeHTML(args[k])
    end
    args
  end

  # 2011-11-29
  def Scraper.build_date4(str)
    array = str.split('-')
    yr = array[0].to_i
    mo = array[1].to_i
    day = array[2].to_i
    Date.civil(yr,mo,day)
  end

  # 12/20/2010
  def Scraper.build_date3(str)
    array = str.split("/")
    yr = array[2].to_i
    mo = array[0].to_i
    day = array[1].to_i
    Date.civil(yr,mo,day)
  end

  def Scraper.build_date2(str)
    array = str.split(/\s+/)
    yr = array[2].to_i
    mo = MONTHS[array[1]]
    d = array[0].to_i
    Date.civil(yr,mo,d)
  end

# Oct 20, 2011 or October 20, 2011
  def Scraper.build_date(str)
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

  def Scraper.day(str)
    str =~ /\s(\d+),/
    $1
  end

  def Scraper.year(str)
    str =~ /(\d\d\d\d)/
    $1
  end

  # takes an array of objects
  # concatenates their .to_s
  # makes a hex digest of the result
  def Scraper.unique_key(hash)
    str = hash.values.each_with_object(""){ |elt, s| s << elt.to_s }
    Digest::MD5.hexdigest(str)
  end

end
