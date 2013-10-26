class AmazonScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("Amazon")
    end

    # make sure we don't forget that we need to get 'all' the reviews
    # from Amazon each time

    def page_reviews(doc)
      doc.css("table#productReviews tr td >  div")
    end

    def next_link(doc,link_url,url,klass)
      begin
        # doc.css('span.paging')[0].css('a').select{|a| a.text =~ /Next/}.first[:href]
        # next_link = doc.css('ul.a-pagination > li.a-last a')[0][:href]#.select{|a| a.text =~ /Next/}.first[:href]
        # p link_url
        # next_number = 2
        # if link_url =~ /pageNumber=(\d)/
        #   next_number = $1
        # end
        # puts url
        # puts "#{url}&pageNumber=#{next_number}"
        #doc.css('.CMpaginate a').each{ |a| puts a[:href] }
        #puts doc.css('span.paging').to_s
        #puts doc.css('.CMpaginate span.paging').to_s
        next_link = doc.css('.CMpaginate span.paging').to_s =~ /href="([^>]+)">Next/ ? $1 : nil
        next_link << "&sortBy=bySubmissionDateDescending" unless next_link =~ /bySubmissionDateDescending/
        # unless next_link =~ /bySubmissionDateDescending/
        #   nextLink << "&sortBy=bySubmissionDateDescending"
        # end
        # next_link = doc.css('.paging a').select{|a| a.text =~ /Next/}.first[:href]
        puts "NEXT LINK IS #{next_link}"
        next_link
      rescue
        puts "NO NEXT LINK"
      end
    end

    def url_from_link(link_url)
      "#{link_url.forum.root}#{link_url.link}#{link_url.forum.tail}"
    end

    def get_unique_key(review)
      begin
        review.css("a[name]")[0][:name].split(".")[0]
      rescue
        puts "NO UNIQUE KEY"
      end
    end

    def args_from_review(review)
      text = review.to_s
      date = text =~ /<nobr>([A-z]+ \d{1,2}, \d{4})/ ? $1 : "FAILS"
      if date.eql?("FAILS")
        puts "DATE FAILS"
        return nil
      end
      body = text.gsub(/<div[^>]+>.+?<\/div>/m,"")
      body.gsub!(/<[^b][^>]+>/m,"")
      body ||= "EMPTY"
      location_str = text =~ /By&nbsp\;.+?>[^<]+<\/span><\/a>\s(\([^)]+\))/m ? $1 : ""
      location = location_str.gsub(/[()]/,"").strip
      {
        review_date: build_date(date),
        rating: review.at_css(".swSprite").content.scan(/^\d/)[0].to_i,
        body: body.gsub(/<[^>]+>/,"").strip!,
        headline: text =~ /<b>([^<]+)<\/b>/ ? $1 : "EMPTY",
        author: text =~ /By&nbsp\;.+?>([^<]+)<\/span/m ? $1 : "EMPTY",
        location: location.length > 0 ? location : nil
      }
    end

    def exercise
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
end
