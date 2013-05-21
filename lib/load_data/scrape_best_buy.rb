module ScrapeBestBuy
  require 'load_data/utils'

  def reviews_from_page(doc, product)
    forum = Forum.find_by_name("BestBuy")
    product_link = forum.product_links.where(:product_id => product.id).first
    raise "NO PRODUCT LINK" unless product_link
    reviews = []
    doc.css('div.BVRRContentReview').each do |review|
      args = {}
      args[:unique_key] = review.attr("id").split("_")[1]
      if BestBuyReview.where(:unique_key => args[:unique_key]).first
        puts "Review already exists"
        next
      end
      text = review.css('span.BVRRReviewTitle').text.strip
      args[:headline] = CGI.unescapeHTML(text)
      args[:rating] = review.css('span.BVRRRatingNumber')[0].text.to_i
      text = review.css('span.BVRRNickname').text.strip
      args[:author] = CGI.unescapeHTML(text)
      text = review.css('span.BVRRUserLocation').text.strip
      args[:location] = CGI.unescapeHTML(text)
      date = review.css('span.BVRRReviewDate').text.strip
      args[:review_date] = Utils.build_date3(date)
      text = review.css('span.BVRRReviewText').collect{|c| c.text}.join(" ")
      args[:body] = CGI.unescapeHTML(text)
      args[:product_link_id] = product_link.id
      reviews << BestBuyReview.new(args)
    end
    reviews
  end

  def exercise
    product = Product.find_by_name("QC 15")
    path = "#{Rails.root}/exercise_files/best_buy.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product)
    raise "Incorrect count" unless reviews.size == 8
    raise "Key" unless reviews.map(&:unique_key).eql?(["2157804", "11603198",
      "11590902", "11587980","11585068", "11582093", "11579136", "11578420"])
    raise "Headline" unless reviews.map(&:headline).eql?(["Best headphones out there...",
      "Amazing, just wish they were bluetooth","Nice, clear, quality sound with no external noise.",
      "Works great", "Awesome headset","Anyone who flys should have these",
      "Quiet with excellent sound", "Great headphones"])
    raise "Author" unless reviews.map(&:author).eql?(["TheBigY", "Layoga", "mcw0411", "Eurotraveler",
      "tnuts878", "mjdaven", "mlsande21", "Curt7261Ga"])
    raise "Location" unless reviews.map(&:location).eql?(["WV", "Honolulu, HI", "Boston", "Tampa",
      "Alaska", "Malabar, Fl", "Portland, OR", "Rochester mn"])
    raise "Review date" unless reviews.map(&:review_date).eql?(%w(2010-02-09 2013-05-13
      2013-05-12 2013-05-11 2013-05-11 2013-05-11 2013-05-10 2013-05-10
      ).map{ |d| Date.strptime(d, "%Y-%m-%d") } )
    raise "Body length" unless reviews.map{ |r| r.body.length }.eql?([1175, 778, 205, 108, 212, 203, 309, 84])
    raise "Body 3" unless reviews[3].body.eql?("These are great. I use them on airlines all the time and they" +
      " do a great job of eliminating the engine noise")
    nil
  end

end
