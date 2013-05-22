# product is Bose SoundLink Bluetooth mobile speaker
module ScrapeCnet

    require 'load_data/utils'

  def reviews_from_page(doc, product)
    forum = Forum.find_by_name("Cnet")
    product_link = forum.product_links.where(:product_id => product.id).first
    reviews = []
    doc.css(".rateSum").each do |review|
      args = { :unique_key => review.attr("messageid") }
      if CnetReview.where(:unique_key => args[:unique_key]).first
        puts "Review already exists"
        next
      end
      args[:rating] = review.at_css(".stars").text.sub(/stars/,"").strip.to_i
      date = review.at_css("time").text
      args[:review_date] = Utils.build_date(date)
      headline = review.at_css(".userRevTitle").text.gsub(/\"/, "").strip
      args[:headline] = CGI.unescape(headline)
      author = review.at_css(".author").text.strip || ""
      args[:author] = CGI.unescape(author)
      args[:body] = CGI.unescape(review.at_css(".userReviewBody").text.strip)
      reviews << CnetReview.new(args)
      unless reviews[-1].valid?
        puts reviews[-1].errors.inspect
        raise "Invalid"
      end
    end
    reviews
  end

  def exercise
    product = Product.find_by_name("SoundLink Bluetooth")
    path = "#{Rails.root}/exercise_files/cnet.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product)
    raise "Count" unless reviews.size == 5
    raise "Key" unless reviews.map(&:unique_key).eql?(
      %w(10148281 10150395 10150120 10150113 10146791))
    raise "Rating" unless reviews.map(&:rating).eql?([5, 2, 4, 4, 4])
    raise "Review Date" unless reviews.map(&:review_date).eql?(
      %w(2013-01-13 2013-04-15 2013-04-02 2013-04-01 2012-11-13
      ).map{ |d| Date.strptime(d, "%Y-%m-%d") })
    raise "Headline" unless reviews.map(&:headline).eql?(
      ["Same speaker with even better sound",
        "Great sound horrible bluetooth connectivity.",
        "Great speaker!", "Sounds greatly, and is so portable!",
        "Very good portable speaker! Impressive!"])
    raise "Body length" unless
      reviews.map{|r| r.body.length}.eql?([4069, 465, 385, 254, 346])
    raise "Body" unless reviews[3].body.eql?(
"Pros Small form factor and clear, rich, full sound. Long lasting battery.
Cons Small, small con: A little heavy when you want to carry around, but very portable.
Summary Really love the sound of this portable device; Bose hit another one out of the park!")
  end



end
