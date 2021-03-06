module ScrapeAmazon

  require 'load_data/utils'

  def reviews_from_page(doc, product)
    forum = Forum.find_by_name("Amazon")
    product_link = forum.product_links.where(:product_id => product.id).first
    reviews = []
    doc.css("table#productReviews tr td >  div").each do |review|
      args = {}
      args[:unique_key] = review.css("a[name]")[0][:name].split(".")[0]
      if AmazonReview.where(:unique_key => args[:unique_key]).first
        puts "Review already exists"
        next
      end
      text = review.to_s
      date = text =~ /<nobr>([A-z]+ \d{1,2}, \d{4})/ ? $1 : "FAILS"
      if date.eql?("FAILS")
        puts "DATE FAILS"; next
      end
      args[:review_date] = Utils.build_date(date)
      args[:rating] = review.at_css(".swSprite").content.scan(/^\d/)[0].to_i
      body = text.gsub(/<div[^>]+>.+?<\/div>/m,"")
      body.gsub!(/<[^b][^>]+>/m,"")
      body ||= "EMPTY"
      body.gsub!(/<[^>]+>/,"").strip!
      args[:body] = CGI.unescapeHTML(body)
      headline = text =~ /<b>([^<]+)<\/b>/ ? $1 : "EMPTY"
      args[:headline] = CGI.unescapeHTML(headline)
      author = text =~ /By&nbsp\;.+?>([^<]+)<\/span/m ? $1 : "EMPTY"
      args[:author] = CGI.unescapeHTML(author)
      str = text =~ /By&nbsp\;.+?>[^<]+<\/span><\/a>\s(\([^)]+\))/m ? $1 : "NA"
      args[:location] = str.gsub(/[()]/,"")
      reviews << AmazonReview.new(args)
      raise "INVALID" unless reviews[-1].valid?
    end
    reviews
  end

  def exercise
    product = Product.find_by_name("QC 15")
    path = "#{Rails.root}/exercise_files/amazon.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product)
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
