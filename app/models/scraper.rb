class Scraper < ActiveRecord::Base

  require 'open-uri'

  def Scraper.get_reviews(all_reviews = false)
    klass = "#{forum.name}Review"
    forum.product_links.each do |product_link|
      product_link.link_urls.each do |link_url|
        url = url_from_link(link_url)
        cycle = 0 # check for run-away
        while url && cycle < 100
          doc = doc_from_url(url)
          next unless doc
          url = build_reviews_from_doc(doc,link_url,url,klass,all_reviews)
          cycle += 1
        end
      end
    end
    nil
  end

  def self.url_from_link(link_url)
    "#{link_url.forum.root}#{link_url.link}#{link_url.forum.tail}"
  end

  def self.doc_from_url(url)
    begin
      doc = Nokogiri::HTML(open(url))
    rescue => e
      puts "Unable to get document at #{url}"
      puts e.message
    end
  end

  def Scraper.build_reviews_from_doc(doc,link_url,url,klass,all_reviews)
    count = 0
    review_class = Object.const_get(klass)
    page_reviews(doc).each do |review|
      next unless (key = get_unique_key(review))
      if review_class.where(:unique_key => key).first
        puts "Review already exists"
        next
      end
      args = { unique_key: key, link_url_id: link_url.id }
      begin
        next unless (add_args = args_from_review(review))
      rescue => e
        puts "ERROR #{e.message}"
        return
      end
      args.update(unescape(add_args))
      begin
        the_review = review_class.create!(args)
        count += 1
      rescue => e
        puts e.message
        puts args.inspect
      end
    end
    puts "GOT #{count} REVIEWS"
    # we may need to get all reviews
    (count > 0 || all_reviews) ? next_link(doc,link_url,url,klass) : nil
  end

  def Scraper.unescape(args)
    coder = HTMLEntities.new
    [:headline, :body, :author, :location].each do |k|
      args[k] = coder.decode(args[k])
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

  MONTHS = Hash[
    %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec).zip(Array(1..12))]
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
  def Scraper.build_unique_key(args)
    str = args.values.each_with_object(""){ |elt, s| s << elt.to_s }
    Digest::MD5.hexdigest(str)
  end

end
