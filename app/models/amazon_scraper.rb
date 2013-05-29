class AmazonScraper < Scraper

  def self.forum
    Forum.find_by_name("Amazon")
  end

  def self.harvest_reviews
    get_reviews(forum)
  end

  def self.page_reviews(doc)
    doc.css("table#productReviews tr td >  div")
  end

  def self.next_link(doc)
    begin
      doc.css('span.paging')[0].css('a').select{|a| a.text =~ /Next/}.first[:href]
    rescue
      nil
    end
  end

  def self.get_unique_key(review)
    begin
      review.css("a[name]")[0][:name].split(".")[0]
    rescue
      puts "NO UNIQUE KEY"
    end
  end

  def self.args_from_review(review)
    args = {}
    text = review.to_s
    date = text =~ /<nobr>([A-z]+ \d{1,2}, \d{4})/ ? $1 : "FAILS"
    if date.eql?("FAILS")
      puts "DATE FAILS"
      return nil
    end
    args[:review_date] = build_date(date)
    args[:rating] = review.at_css(".swSprite").content.scan(/^\d/)[0].to_i
    puts "\tRATING #{args[:rating]}"
    body = text.gsub(/<div[^>]+>.+?<\/div>/m,"")
    body.gsub!(/<[^b][^>]+>/m,"")
    body ||= "EMPTY"
    args[:body] = body.gsub(/<[^>]+>/,"").strip!
    args[:headline] = text =~ /<b>([^<]+)<\/b>/ ? $1 : "EMPTY"
    args[:author] = text =~ /By&nbsp\;.+?>([^<]+)<\/span/m ? $1 : "EMPTY"
    str = text =~ /By&nbsp\;.+?>[^<]+<\/span><\/a>\s(\([^)]+\))/m ? $1 : "NA"
    args[:location] = str.gsub(/[()]/,"")
    args
  end

  def self.exercise
    product = Product.find_by_name("QC 15")
    link_url = forum \
      .product_links.where(:product_id => product.id).first.link_urls.first
    path = "#{Rails.root}/exercise_files/amazon.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product,"Amazon")
    raise "Count" unless reviews.count == 10
    raise "Rating" unless reviews.map(&:rating).eql?([5, 5, 5, 4, 4, 5, 4, 5, 4, 5])
    keys = reviews.map(&:unique_key)
    raise "Key" unless reviews.map(&:unique_key).eql?(%w(R1L8GF5OCSIFZ3 R3V001MH2EFO3Y
      R3ICSEC83QTK6C R2YPI6BRBIWJU4 R1IW7Q0Q70OCQ RV9KHTDCYASZL RUA2XXC5A8DQL
      RIZDMNCS03J84 RVTAUECEAUCYD R3TTPNZZCD0IEW))
    raise "Date" unless reviews.map(&:review_date).eql?(%w(2013-05-13 2013-05-12 2013-05-12
      2013-05-12 2013-05-11 2013-05-11 2013-05-11 2013-05-11 2013-05-09 2013-05-09
      ).map{ |d| Date.strptime(d, "%Y-%m-%d") })
    raise "Author" unless reviews.map(&:author).eql?(["Chacharice", "Hayhoitsofftoworkwego", "Toni",
      "evilmaniac", "Paul", "Valdemar M Fracz", "Gunter Van Deun", "Uncle Jams", "S. Power", "Sister T. Considine"])
    raise "Headline" unless reviews.map(&:headline).eql?(["fantastic",
      "Excellent Bose Quiet Comfort 15 Acoustic Noise Cancelling headphones", "Wonderful", "Better than before",
      "really good headphone", "Impressive", "Glad I purchased it !", "These cans are amazing!",
      "There is still room for improvement, but compared to previous models and competitors they are great",
      "Great for a good night's sleep"])
    raise "Location" unless reviews.map(&:location).eql?(["NA", "NA", "GA", "NA", "NA", "NA", "NA", "NA",
      "Austin, Texas, United States", "Atherton, CA United States"])
    raise "Body length" unless reviews.map{ |r| r.body.length }.eql?([298, 400, 256, 356, 205, 149, 636, 439, 1370, 175])
    raise "First body" unless reviews.first.body.eql?("I don't know too much about headphones, " +
    "but going from my regular earbuds to these headphones have significantly improved my listening " +
    "experience and focus at work. I share an office with a tech gal who often has visitors and meetings, " +
    "so the headphones have helped me focus and get some work done.")
    nil
  end
end
