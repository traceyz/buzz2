module ScrapeApple

  require 'load_data/utils'

  def reviews_from_page(doc, product)
    forum = Forum.find_by_name("Apple")
    product_link = forum.product_links.where(:product_id => product.id).first
    raise "NO PRODUCT LINK" unless product_link
    reviews = []
    doc.css('.review').each do |review|
      args = {}
      args[:unique_key] = review.css('input[name="voteId"]').attr("value").text
      if AppleReview.where(:unique_key => args[:unique_key]).first
        puts "Review already exists"
        next
      end
      args[:rating] = review.css('span[@itemprop="ratingValue"]').text.to_i
      str = review.css('h2.summary').text.strip
      args[:headline] = CGI.unescape(str)
      str = review.css('span[@itemprop="author"]').text
      args[:author] = CGI.unescape(str)
      str = review.css('ul.statistics > li').first.text.strip
      location_str = str =~ /.+from (.+)\Z/ ? $1 : "NA"
      args[:location] = CGI.unescape(location_str)
      date_str = review.css('time').attr('datetime').text
      args[:review_date] = Utils.build_date4(date_str)
      str = review.css('p.description').text.strip
      args[:body] = CGI.unescape(str)
      ap_review = AppleReview.new(args)
      raise "Invalid" unless ap_review.valid?
      reviews << ap_review
    end
    reviews
  end

  def exercise
    product = Product.find_by_name("Bluetooth Headset Series 2")
    path = "#{Rails.root}/exercise_files/apple.html"
    doc = Nokogiri::HTML(open(path))
    reviews = reviews_from_page(doc, product)
    raise "#{reviews.count} COUNT != 20" unless reviews.count == 20
    raise "Date" unless reviews.map(&:review_date).eql?(%w(
      2013-05-09 2013-03-24 2013-02-18 2013-02-08 2013-02-02
      2013-02-01 2012-12-14 2012-12-01 2012-10-27 2012-09-20
      2012-07-12 2012-07-11 2012-07-11 2012-07-03 2012-04-30
      2012-04-18 2012-03-20 2012-02-29 2012-02-26 2012-02-08) \
       .map { |s| Date.strptime(s, "%Y-%m-%d")} )
    raise "Author" unless reviews.map(&:author).eql?(
      ["Jeff A", "Martin W", "Randy C", "KENNETH M", "Randy F",
      "Phillip B", "Ben F", "Robert S. K", "JONATHAN M", "MICHAEL F", "Sebastien M",
      "GENE K", "russell M", "Majed H", "Julia B", "Eileen C", "Greg H", "ROBERT P",
      "Matthew H", "Jonathan T"])
    raise "Headline" unless reviews.map(&:headline).eql?(["Problems with Pairing to My iPhone 4",
      "It's over", "Works great.", "No Comparisons", "Buy It. Nothing Else Compares.",
      "Best Bluetooth headset I've owned", "Good but not good enough", "Excellent Sound But Cheap Construction",
      "Worth the money", "Bose is so good at packing in so much 'oomph' into such small products",
      "It changed my life!", "Over Rated", "bose bluetooth ear piece", "simply the BEST!!",
      "Love it!", "having trouble", "Best of all the ones I've owned in the past five years!",
      "Works great and very comfortable.", "Does not work on iTouch 4th Generation", "By far the best!"])
    raise "Body length" unless reviews.map{ |r| r.body.length }.eql?([1131, 875, 2047, 231, 395, 288, 951,
      462, 414, 779, 62, 726, 75, 414, 418, 243, 2602, 1036, 87, 258])
    raise "Last body error" unless reviews[-1].body.eql?(
      "This is the best Bluetooth ever. I am a truck driver and it can get really loud " <<
      "in the cab, but no worries with this. Fits better than any headphone out there and has " <<
      "a lot of volume as well as the clarity of my voice is great. Must buy and is well worth it.")
    raise "Location" unless reviews.map(&:location).eql?(
    ["Mansfield", "Staten island", "Broadlands", "SOUTH PASADENA", "Panama City", "Walnut Creek",
      "Sudbury", "MILWAUKEE", "Clifton Park", "FAIR LAWN", "Quebec", "CHICAGO", "tewksbury",
      "Chicago", "San Antonio", "Tinley park", "Buford", "Santa Barbara", "Lancaster", "Hagerstown"])
    raise "Key" unless reviews.map(&:unique_key).eql?(
    keys = ["RYT4CC7D9AK2K9P4C", "R9T7FU94CDX2U4UXY", "RDYDHHCU9UDK2AHFC",
      "RFP9FHHFAPTXTXTH7", "RCAXKY79HUXXHCAJX", "RPKYU4J9PDD2FHUAD", "RKJPXT2UYPXAK9HPC",
      "RX7XUD9PXX94KKPKT", "RAP7U7YPF9X72DFU7", "RCXUYFCCD2XKYKDTK", "R7T9CKAJUAUUYAT79",
      "R2DUH47K9YHUU74XY", "RUFX9HJF2TDUYDJCA", "RU2J944PUJH7THF94", "RCYXUAKDU42YUU4A4",
      "RXUH9TTUDKCTK2JH7", "RK7DXPUUACPTKPPPA", "RADCYFYX7U27XHXF9", "RFC42PFFX2JTK4UXF",
      "RX44TP272YFKF4AUK"])
    nil
  end

end

