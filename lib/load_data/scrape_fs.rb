# product is AE2
module ScrapeFs

    require 'load_data/utils'

  def reviews_from_page(doc, product)
    forum = Forum.find_by_name("Cnet")
    product_link = forum.product_links.where(:product_id => product.id).first
    reviews = []
    # note that since FutureShop does not reveal any unique identifier
    # we have to use a different approach to building the reviews
    # and the args hash
    doc.css(".customer-review-item").each do |review|
      args = { :rating => review.at_css(".rating-score").text.to_i }
      args[:author] = CGI.unescape(review.at_css(".name").text.strip)
      loc = review.at_css(".loc").text.strip.sub(/from /,'')
      args[:location] = CGI.unescape(loc)
      date = review.at_css(".date").text.strip
      if date =~ /(\d+) days ago/
        d = Time.now - ($1.to_i * 60 * 60 * 24)
        review_date = Utils.build_date4("#{d.year}-#{d.month}-#{d.day}")
      else
        review_date = Utils.build_date(date.strip)
      end
      # there are some with xx minutes ago - get them next spin
      args[:review_date] = review_date
      h = review.at_css(".customer-review-title").text.strip
      args[:headline] = CGI.unescape(h)
      args[:body] = CGI.unescape(review.at_css("p").text.strip)
      args[:unique_key] = Utils.unique_key(args)
      if FutureShopReview.where(:unique_key => args[:unique_key]).first
        puts "Review already exists"
        next
      end
      reviews << FutureShopReview.new(args)
      raise "Invalid" unless reviews[-1].valid?
    end
    reviews
  end

  def exercise
    product = Product.find_by_name("AE2")
    path = "#{Rails.root}/exercise_files/fs.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product)
    raise "Count" unless reviews.size == 5
    raise "Rating" unless reviews.map(&:rating).eql?([5, 1, 5, 5, 4])
    raise "Author" unless reviews.map(&:author).eql?(
      ["Hamza", "Disappointed Customer", "Dave", "Jacques", "Bob"])
    raise "Location" unless reviews.map(&:location).eql?(
      ["Toronto, ON", "Toronto, ON", "Sydney, NS", "Calgary", "Ancaster"])
    raise "Review date" unless reviews.map(&:review_date).eql?(
      %w(2012-12-04 2012-11-21 2012-09-28 2012-03-26 2012-01-20
      ).map{ |d| Date.strptime(d, "%Y-%m-%d") })
    raise "Headline" unless reviews.map(&:headline).eql?(
["i love them", "Shrill highs, weak mids & anemic bass", "Great sound",
  "amazing sound and comfort!!!!", "Really good customer service"])
    raise "Body length" unless reviews.map{|r| r.body.length}.eql?(
      [300, 1405, 333, 373, 642])
    raise "First review body" unless reviews.first.body.eql?(
"not really for electronic music or DJ-ing.. but the build quality and the comfort is awesome.
as far as the sound is concerned it has awesome highs and mids..a little low on bass but thats okay.. i still enjoy electronic music on them.
you will forget they are on after the first 20 mins.
MUST BUY :)")
    raise "Unique Key" unless reviews.map(&:unique_key).eql?(%w(
        f391d15ab0c76ee11c39edc1e04a9e1c
        abfeab5ef05f2db0d3d02e4768c66222
        a4e44a01ed2d72b696081a801c369b68
        22bedb2c1d3c89c4e38beb34c1a6fce9
        07642f344941586e2ff1bdc68ff6269b))
  end

end
