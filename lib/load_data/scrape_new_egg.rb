module ScrapeNewEgg

  require 'load_data/utils'

  def reviews_from_page(doc, product)
    forum = Forum.find_by_name("NewEgg")
    product_link = forum.product_links.where(:product_id => product.id).first
    raise "NO PRODUCT LINK" unless product_link
    reviews = []
    doc.css('tbody tr').each do |review|
      args = {:unique_key => review.at_css("form").attr("name").gsub(/\D/,'')}
      if NewEggReview.where(:unique_key => args[:unique_key]).first
        puts "Review already exists"
        next
      end
      author = review.at_css('th.reviewer em').content
      args[:author] = CGI.unescape(author)
      date = review.css('th.reviewer ul li')[1].content.scan(/\d+\/\d+\/\d+/)[0]
      args[:review_date] = Utils.build_date3(date)
      postdate = review.at_css('h3')
      args[:headline] = postdate.content.split('/5').last
      args[:rating] = postdate.at_css('img.eggs')[:alt].scan(/^\d/)[0]
      comments = review.css('div.details p')
      args[:body] = comments.collect{|c| c.content.gsub(/<em\>/,"").gsub(/<\/em>/,"")}.join(" ")
      reviews << NewEggReview.new(args)
      raise "Invalid" unless reviews[-1].valid?
    end
    reviews
  end

  def exercise
    product = Product.find_by_name("OE2")
    path = "#{Rails.root}/exercise_files/newegg.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product)
    raise "Count" unless reviews.size == 2
    raise "Key" unless reviews.map(&:unique_key).eql?(%w(3476935 3413196))
    raise "Author" unless reviews.map(&:author).eql?(["Matt", "cms10"])
    raise "Date" unless reviews.map(&:review_date).eql?(%w(
      2012-08-23 2012-06-22).map{|d| Date.strptime(d, "%Y-%m-%d") } )
    raise "Headline" unless reviews.map(&:headline).eql?(["I love these.", "Wonderful Headphones"])
    raise "Rating" unless reviews.map(&:rating).eql?([5,5])
    raise "Body length" unless reviews.map{|r| r.body.length}.eql?([447, 1412])
  end

end
