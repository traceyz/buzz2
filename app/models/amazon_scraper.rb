class AmazonScraper < Scraper

  require "net/http"
  require "uri"

  class << self

    def forum
      Forum.where(:name => "Amazon").first
    end

    # make sure we don't forget that we need to get 'all' the reviews
    # from Amazon each time

    def page_reviews(doc)
      reviews = doc.css("table#productReviews tr td >  div")
      puts "THERE ARE #{reviews.count} REVIEWS ONTHIS PAGE"
      reviews
    end

    def specific_product(product_link)
      true
    end

    def next_link(doc,link_url,url,klass)
      if doc.to_s !~ /<a[^>]+>Next/i
        puts "Match 22"
        return nil
      elsif url =~ /(.+)top_link_1\?/ # careful, lest it it get confused by top_link_10
        puts "MATCH 26"
        "#{$1}top_link_2?ie=UTF8&pageNumber=2&showViewpoints=0"
      elsif url =~ /(.+)top_link_(\d+)/
        puts "MATCH 29"
        page = $2.to_i+1
        "#{$1}top_link_#{page}?ie=UTF8&pageNumber=#{page}&showViewpoints=0"
      # elsif url =~ /(.+)top_recent_(.+)UTF8(.+)/
      #   puts "Match 25"
      #   "#{$1}next_2#{$2}UTF8&page_number=2" ##{$3}"
      # elsif url =~ /(.+)top_link_1/
      #   puts "Match 28"
      #   "#{$1}top_link_2?ie=UTF8&pageNumber=2" #&showViewpoints=0&sortBy=bySubmissionDateDescending"
      # elsif url =~ /(.+)top_link_(\d+)/
      #   puts "Match 30"
      #   page = $2.to_i + 1
      #   "#{$1}top_link_#{page}?ie=UTF8&pageNumber=#{page}" #&showViewpoints=0&sortBy=bySubmissionDateDescending"
      # elsif url =~ /(.+)next_(\d+)(.+)page_number=(\d+)(.+)/
      #   puts "Match 35"
      #   page = $2.to_i + 1
      #   "#{$1}next_#{page}#{$3}pageNumber=#{page}"##{$5}"
      # elsif url =~ /(.+)next_(\d+)(.+)pageNumber=(\d+)(.+)/
      #   puts "Match 39"
      #   page = $2.to_i + 1
      #   "#{$1}next_#{page}#{$3}pageNumber=#{page}"##{$5}"
      else
        puts "NO MATCH FOR #{url}"
      end
      # begin
      #   # doc.css('span.paging')[0].css('a').select{|a| a.text =~ /Next/}.first[:href]
      #   # next_link = doc.css('ul.a-pagination > li.a-last a')[0][:href]#.select{|a| a.text =~ /Next/}.first[:href]
      #   # p link_url
      #   # next_number = 2
      #   # if link_url =~ /pageNumber=(\d)/
      #   #   next_number = $1
      #   # end
      #   # puts url
      #   # puts "#{url}&pageNumber=#{next_number}"
      #   #doc.css('.CMpaginate a').each{ |a| puts a[:href] }
      #   #puts doc.css('span.paging').to_s
      #   #puts doc.css('.CMpaginate span.paging').to_s
      #   next_link = doc.css('.CMpaginate span.paging').to_s =~ /href="([^>]+)">Next/ ? $1 : nil
      #   next_link << "&sortBy=bySubmissionDateDescending" unless next_link =~ /bySubmissionDateDescending/
      #   # unless next_link =~ /bySubmissionDateDescending/
      #   #   nextLink << "&sortBy=bySubmissionDateDescending"
      #   # end
      #   # next_link = doc.css('.paging a').select{|a| a.text =~ /Next/}.first[:href]
      #   puts "NEXT LINK IS #{next_link}"
      #   next_link
      # rescue
      #   puts "NO NEXT LINK"
      # end
    end

    def url_from_link(link_url)
      url = "#{link_url.forum.root}#{link_url.link}#{link_url.forum.tail}"
      puts "URL FROM LINK => LINK IS #{url}"
      url
    end

    def get_unique_key(review)
      begin
        review.css("a[name]")[0][:name].split(".")[0]
      rescue
        puts "NO UNIQUE KEY"
      end
    end

    def get_date(review)
      text = review.to_s
      text =~ /<nobr>[A-z]+ \d{1,2}, (\d{4})/
      $1.to_i
    end

    def args_from_review(review, link_url)
      # for some reason, these are slipping into the scraper
      retun nil if link_url.link.start_with?('Cosmos-Pattern-Protection')
      text = review.to_s
      date = text =~ /<nobr>([A-z]+ \d{1,2}, \d{4})/ ? $1 : "FAILS"
      if date.eql?("FAILS")
        puts "DATE FAILS"
        return nil
      end
      #body = text.gsub(/<div[^>]+>.+?<\/div>/m,"")
      body = review.at_css('div.reviewText').text
      # puts
      # puts "#" * 50
      # puts body
      raise "EMPTY AMAZON BODY" unless body.length > 0
      # body.gsub!(/<[^b][^>]+>/m,"")
      # body ||= "EMPTY"
      #body = body.gsub(/<[^>]+>/,"").strip!
      location_str = text =~ /By&nbsp\;.+?>[^<]+<\/span><\/a>\s(\([^)]+\))/m ? $1 : ""
      location = location_str.gsub(/[()]/,"").strip
      #review_from = text =~ /This review is from: <\/span>[^>]+>Bose ([^>]+)<\/a/m ? $1 : nil
      review_from = text =~ /(This review is from:.+?)<\/b/m ? $1 : nil
      rf = nil
      if review_from
        #puts "REVIEW FROM ***#{review_from}***"
        cleaned = ReviewFrom.clean(review_from)
        rf = ReviewFrom.where(:phrase => cleaned).first
        unless rf
          File.open("#{Rails.root}/missing_rfs_#{Date.today}.txt", 'a') do |f|
            f.puts "\nNO REVIEW FROM FOR: #{cleaned}"
            f.puts "LinkUrl id: #{link_url.id}"
            f.puts "Link: #{link_url.link}"
            f.puts "Titile: #{link_url.title}"
          end
          return nil
          # puts "NO REVIEW FROM FOR **#{cleaned}**"
          # print "Enter product id: "
          # product_id = gets.chomp
          # unless product_id && product_id.length > 0
          #   puts "Skipping #{cleaned}"
          #   return nil
          # else
          #   rf = Product.find(product_id.to_i).review_froms.create!(:phrase => cleaned)
          # end
        end
      else
        puts "NO REVIEW FROM"
      end
      rf_id = rf ? rf.id : nil
      {
        review_date: build_date(date),
        rating: review.at_css(".swSprite").content.scan(/^\d/)[0].to_i,
        body: body, #.gsub(/<[^>]+>/,"").strip!,
        headline: text =~ /<b>([^<]+)<\/b>/ ? $1 : "EMPTY",
        author: text =~ /By&nbsp\;.+?>([^<]+)<\/span/m ? $1 : "EMPTY",
        location: location.length > 0 ? location : nil,
        review_from_id: rf_id
      }
    end

    def update_product_ids
      AmazonReview.where("product_id IS NULL").each do |review|
        if review.review_from
          review.product_id = review.review_from.product_id
        else
          review.product_id = review.link_url.product_link.product_id
        end
        review.save!
      end
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

    def find_body
      path = "#{Rails.root}/exercise_files/amazon_body.html"
      doc = Nokogiri::HTML(open(path))
      product = Product.where(:name => "AM 5").first
      doc = Nokogiri::HTML(open(path))
      reviews = doc.css("table#productReviews tr td >  div")
      puts reviews.first.at_css('div.reviewText').text
    end


    def reviews_from_file(link_url_id)
      path = "#{Rails.root}/app/models/az_files/index"
      doc = Nokogiri::HTML(open(path))
      link_url = LinkUrl.find(link_url_id)
      build_reviews_from_doc(doc, link_url, "", "AmazonReview", true)
    end

    def ajax_reviews(codes = nil)
      existing_keys = Set.new(AmazonReview.where("review_date >= '2014-01-01'").map(&:unique_key))
      new_reviews = 0
      codes ||= get_all_codes
      uri = URI.parse("http://www.amazon.com/ss/customer-reviews/ajax/reviews/get/ref=cm_cr_pr_top_recent")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      codes.each do |code|
        offset = 0
        form_data = {"asin" => code, "reviewerType" => "all_reviews", "filterByStar" => "all_stars",
          "formatType" => "all_formats", "sortBy" => "recent", "count" => 10}
        response = next_ajax_response(http, request, form_data, 0)
        #response = http.request(request)
        status = response.code
        puts "\nSTATUS IS #{status} for #{code}"
        next unless status == "200"
        doc = Nokogiri::HTML(response.body)
        unless doc.css('span.review-count-total').first
          puts "NO REVIEWS"
          next
        end
        total_reviews = doc.css('span.review-count-total').first.content.scan(/\d+/).first
        puts "TOTAL REVIEWS #{total_reviews}"
        showing =  doc.css('span.review-count-shown').first.content
        puts "SHOWING #{showing}"
        if showing =~ /\d+-(\d+)/
          last_showing = $1.to_i
          puts "LAST SHOWING #{last_showing}"
        else
          puts "NO LAST SHOWING"
        end
        reviews = doc.css('.review')
        puts "REVIEW COUNT #{reviews.count}"
        reviews.each do |review|
           puts
          rows = review.css('.a-row')
          author_date =  rows[2].content # author and date
          unless author_date =~ /UTC 2014/
            puts "TOO OLD"
            break
          end

          unique_key =  review.attributes['id'].value
          puts "UNIQUE KEY #{unique_key}"
          unless existing_keys.add?(unique_key)
            puts "ALREADY EXISTS"
            next # I tried break but only got 248 reviews instead of 259
            # some small number of review lists are still not in descending order ?
          end

          new_reviews += 1
          rating = rows[1].to_s.scan(/a-star-\d/)[0] # rating
          puts "RATING #{rating}"
          headline =  rows[1].content # headline
          puts "HEADLINE #{headline}"

          puts "AUTHOR / DATE  #{author_date}"
          style = rows[3].at_css('span.a-size-mini')
          puts "STYLE #{style.content}" if style
          body = rows[3].css('.a-section').each{|s| puts s.content.strip} # review
          puts body # returns a zero
        end
      end
      puts "NEW REVIEWS: #{new_reviews}"
      nil
    end

    def next_ajax_response(http, request, form_data, offset)
      form_data["offset"] = offset
      request.set_form_data(form_data)
      http.request(request)
    end

    def get_all_codes
      codes = []
      Forum.find(1).product_links.each do |pl|
        pl.link_urls.each do |lu|
          link = lu.link
          if link =~ /\/([A-Z0-9]+)\z/
            codes << $1
          end
        end
      end
      codes.uniq
    end

  end # self
end

# first 20 codes ["B001DOHYS8", "B00356PVLE", "B001DE4D5U", "B001DP9002", "B001DPB1XG", "B000GFPTQY", "B00022RV6C", "B008RQG1BG", "B00006WNKQ", "B00006J054", "B00GQ0R64Q", "B00006J055", "B00006L7RT", "B00006L7RV", "B00006L7RW", "B000A0HFKI", "B00011CNWG", "B000HWV8QG", "B0091EBU28", "B007ZDEAT2", "B00478O0JI"]
