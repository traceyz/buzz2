module ScrapeAmazon

  require 'load_data/utils'

  def reviews_from_page(doc, product)
    forum = Forum.find_by_name("Amazon")
    product_link = forum.product_links.where(:product_id => product.id).first
    reviews = []
    doc.css("table#productReviews tr td >  div").each do |review|
      text = review.to_s
      date = text =~ /<nobr>([A-z]+ \d{1,2}, \d{4})/ ? $1 : "FAILS"
      if date.eql?("FAILS")
        puts "DATE FAILS"
        puts text
        next
      end
      review_date = Utils.build_date(date)
      unique_key = review.css("a[name]")[0][:name].split(".")[0]
      if AmazonReview.where(:unique_key => unique_key).first
        puts "record already exsists"
        next
      end
      rating = review.at_css(".swSprite").content.scan(/^\d/)[0].to_i
      body = text.gsub(/<div[^>]+>.+?<\/div>/m,"")
      body.gsub!(/<[^b][^>]+>/m,"")
      body ||= "EMPTY"
      body.gsub!(/<[^>]+>/,"").strip!
      body = CGI.unescapeHTML(body)
      headline = text =~ /<b>([^<]+)<\/b>/ ? $1 : "EMPTY"
      headline = CGI.unescapeHTML(headline)
      author = text =~ /By&nbsp\;.+?>([^<]+)<\/span/m ? $1 : "EMPTY"
      author = CGI.unescapeHTML(author)
      location = text =~ /By&nbsp\;.+?>[^<]+<\/span><\/a>\s(\([^)]+\))/m ? $1 : "NA"
      location.gsub!(/[()]/,"")
      ar = AmazonReview.new(:review_date => review_date,
                                            :rating => rating,
                                            :author => author,
                                            :headline => headline,
                                            :body => body,
                                            :author => author,
                                            :location => location,
                                            :unique_key => unique_key,
                                            :product_link_id => product_link.id
        )
      raise "INVALID" unless ar.valid?
      reviews << ar
    end
    reviews
  end

  def exercise
    product = Product.find_by_name("QC 15")
    path = "#{Rails.root}/exercise_files/amazon.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product)
    raise "review count #{reviews.count} != 10" unless reviews.count == 10
    ratings = reviews.map(&:rating)
    raise "#{ratings} dont match [5, 5, 5, 4, 4, 5, 4, 5, 4, 5]" unless ratings.eql?([5, 5, 5, 4, 4, 5, 4, 5, 4, 5])
    keys = reviews.map(&:unique_key)

    correct_keys = ["R1L8GF5OCSIFZ3", "R3V001MH2EFO3Y", "R3ICSEC83QTK6C", "R2YPI6BRBIWJU4",
      "R1IW7Q0Q70OCQ", "RV9KHTDCYASZL", "RUA2XXC5A8DQL", "RIZDMNCS03J84", "RVTAUECEAUCYD",
      "R3TTPNZZCD0IEW"]

    keys.each_with_index do |key, idx|
      raise "#{key} != #{correct_keys[idx]}" unless key.eql?(correct_keys[idx])
    end
    dates = reviews.map(&:review_date)
    correct_dates = [Date.civil(2013,5,13),Date.civil(2013,5,12),Date.civil(2013,5,12),Date.civil(2013,5,12),Date.civil(2013,5,11),
                              Date.civil(2013,5,11),Date.civil(2013,5,11),Date.civil(2013,5,11),Date.civil(2013,5,9),Date.civil(2013,5,9)]
    dates.each_with_index do |date,idx|
      raise "#{date} idx #{idx} != #{correct_dates[idx]}" unless date .eql?(correct_dates[idx])
    end
    authors = reviews.map(&:author)
    correct_authors = ["Chacharice", "Hayhoitsofftoworkwego", "Toni", "evilmaniac", "Paul",
      "Valdemar M Fracz", "Gunter Van Deun", "Uncle Jams", "S. Power", "Sister T. Considine"]
    authors.each_with_index do |author, idx|
      raise "#{author} != #{correct_authors[idx]}" unless author.eql?(correct_authors[idx])
    end
    headlines = reviews.map(&:headline)
    correct_headlines = ["fantastic", "Excellent Bose Quiet Comfort 15 Acoustic Noise Cancelling headphones",
      "Wonderful", "Better than before", "really good headphone",
      "Impressive", "Glad I purchased it !", "These cans are amazing!",
      "There is still room for improvement, but compared to previous models and competitors they are great",
      "Great for a good night's sleep"]
    headlines.each_with_index do |headline,idx|
      raise "#{headline} != #{correct_headlines[idx]}" unless headline.eql?(correct_headlines[idx])
    end
    locations = reviews.map(&:location)
    correct_locations = ["NA", "NA", "GA", "NA", "NA", "NA", "NA", "NA",
      "Austin, Texas, United States", "Atherton, CA United States"]
    locations.each_with_index do |location,idx|
      raise "#{location} != #{correct_locations[idx]}" unless location.eql?(correct_locations[idx])
    end
    lengths = reviews.map { |r| r.body.length }
    correct_lengths = [298, 400, 256, 356, 205, 149, 636, 439, 1370, 175]
    lengths.each_with_index do |length, idx|
      raise "#{length} != #{correct_lengths[idx]}" unless length == correct_lengths[idx]
    end
    correct_body = "I don't know too much about headphones, but going from my regular " +
    "earbuds to these headphones have significantly improved my listening experience and " +
    "focus at work. I share an office with a tech gal who often has visitors and meetings, " +
    "so the headphones have helped me focus and get some work done."
    raise "first body doesn't match" unless reviews.first.body.eql?(correct_body)
    nil
  end
end
