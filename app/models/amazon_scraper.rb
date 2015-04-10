class AmazonScraper < Scraper

  require "net/http"
  require "uri"

  STYLE_PRODUCTS = {
    "SoundTouch Portable" => 95,
    "SoundTouch 20" => 96,
    "SoundTouch 30" => 97
  }

  class << self

    def forum
      Forum.where(:name => "Amazon").first
    end

    # make sure we don't forget that we need to get 'all' the reviews
    # from Amazon each time

    def page_reviews(doc)
      # reviews = doc.css("table#productReviews tr td >  div")
      reviews = doc.css('.review')
      puts "THERE ARE #{reviews.count} REVIEWS ON THIS PAGE"
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
      else
        puts "NO MATCH FOR #{url}"
      end
    end

    def url_from_link(link_url)
      url = "#{link_url.forum.root}#{link_url.link}#{link_url.forum.tail}"
      puts "URL FROM LINK => LINK IS #{url}"
      url
    end

    def get_unique_key(review)
      begin
        #review.css("a[name]")[0][:name].split(".")[0]
        review.attributes['id'].value
      rescue
        puts "NO UNIQUE KEY"
      end
    end

    def get_date(review)
      date_str = review.at_css('.review-date').content
      if date_str =~ /on ([A-z]+) (\d+), (\d+)/
        # puts "#{$1} #{$2}, #{$3}"
        month = MONTHS[$1[0..2]]
        day = $2.to_i
        year = $3.to_i
        #puts "#{month} #{day} #{year}"
      else
        puts "NO DATE FOR #{date_str}"
      end
      [year, month, day]
    end

    def args_from_review(review, link_url, day, month, year)
      # for some reason, these are slipping into the scraper
      product_id = link_url.product.id
      puts "IN ARGS FROM REVIEW"
      rating = review.at_css('span.a-icon-alt').content
      puts "RATING #{rating}"
      headline = review.at_css('a.review-title').content
      puts "HEADLINE #{headline}"
      author = review.at_css('a.author').content
      puts "AUTHOR #{author}"
      body = review.at_css('span.review-text').content
      puts "BODY #{body}"
      review_date = "#{year}-#{month}-#{day}"
      review.css('span.a-color-secondary').each do |stub|
        if stub.content =~ /Style Name: Bose (.+)/
          puts "STUB CONTENT #{stub.content}"
          puts STYLE_PRODUCTS[$1]
          product_id = STYLE_PRODUCTS[$1]
        end
      end
      return {
        :rating => rating,
        :headline => headline,
        :author => author,
        :body => body,
        :review_date => review_date,
        :product_id => product_id
      }
     #  if link_url.link.start_with?('Cosmos-Pattern-Protection')
     #    puts "COSMOS LINK :-("
     #    return nil
     #  end
     #  text = review.to_s
     #  puts "HAVE TEXT FOR ARGS FROM REVIEW"
     #  # date = text =~ /<nobr>([A-z]+ \d{1,2}, \d{4})/ ? $1 : "FAILS"
     #  # if date.eql?("FAILS")
     #  #   puts "DATE FAILS"
     #  #   return nil
     #  # end
     #  #body = text.gsub(/<div[^>]+>.+?<\/div>/m,"")
     #  body_elt = review.at_css('div.reviewText')
     #  unless body_elt
     #    puts "NO BODY"
     #    return {}
     #  end
     #  body = body_elt.text
     #  raise "EMPTY AMAZON BODY" unless body.length > 0
     #  location_str = text =~ /By&nbsp\;.+?>[^<]+<\/span><\/a>\s(\([^)]+\))/m ? $1 : ""
     #  location = location_str.gsub(/[()]/,"").strip
     #  review_from = text =~ /(This review is from:.+?)<\/b/m ? $1 : nil
     #  rf = nil
     #  if review_from
     #    #puts "REVIEW FROM ***#{review_from}***"
     #    cleaned = ReviewFrom.clean(review_from)
     #    rf = ReviewFrom.where(:phrase => cleaned).first
     #    unless rf
     #      puts "NO RF RECORD FOR #{cleaned}"
     #      File.open("#{Rails.root}/missing_rfs_#{Date.today}.txt", 'a') do |f|
     #        f.puts "\nNO REVIEW FROM FOR: #{cleaned}"
     #        f.puts "LinkUrl id: #{link_url.id}"
     #        f.puts "Link: #{link_url.link}"
     #        f.puts "Title: #{link_url.title}"
     #      end
     #      return nil
     #    end
     #  else
     #    puts "NO REVIEW FROM PHRASE"
     #  end
     #  rf_id = rf ? rf.id : nil
     #  #month = MONTHS[month[0..2]]
     # {
     #    review_date: "#{year}-#{month}-#{day}",
     #    rating: review.at_css(".swSprite").content.scan(/^\d/)[0].to_i,
     #    body: body, #.gsub(/<[^>]+>/,"").strip!,
     #    headline: text =~ /<b>([^<]+)<\/b>/ ? $1 : "EMPTY",
     #    author: text =~ /By&nbsp\;.+?>([^<]+)<\/span/m ? $1 : "EMPTY",
     #    location: location.length > 0 ? location : nil,
     #    review_from_id: rf_id
     #  }
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

    def find_body
      path = "#{Rails.root}/exercise_files/amazon_body.html"
      doc = Nokogiri::HTML(open(path))
      product = Product.where(:name => "AM 5").first
      doc = Nokogiri::HTML(open(path))
      reviews = doc.css("table#productReviews tr td >  div")
      puts reviews.first.at_css('div.reviewText').text
    end


    def chrome_reviews_from_file(link_url_id)
      path = "#{Rails.root}/app/models/az_files/index.html"
      doc = Nokogiri::HTML(open(path))
      # doc.css('span.a-color-secondary').each do |stub|
      #   if stub.content =~ /Style Name: Bose (.+)/
      #     puts STYLE_PRODUCTS[$1]
      #   end
      # end
      link_url = LinkUrl.find(link_url_id)
      build_reviews_from_doc(doc, link_url, "", "AmazonReview", true)
    end

        FIRST_20_CODES =[
  "B001DOHYS8", "B00356PVLE", "B001DE4D5U", "B001DP9002", "B001DPB1XG",
  "B000GFPTQY", "B00022RV6C", "B008RQG1BG", "B00006WNKQ", "B00006J054",
  "B00GQ0R64Q", "B00006J055", "B00006L7RT", "B00006L7RV", "B00006L7RW",
  "B000A0HFKI", "B00011CNWG", "B000HWV8QG", "B0091EBU28", "B007ZDEAT2" ]

    def ajax_reviews(codes = nil)
      processed_keys = Set.new(AmazonReview.where("review_date >= '2013-12-01'").map(&:unique_key))
      puts "PRIOR KEYS #{processed_keys.count}"
      codes_to_keys = get_all_codes
      #codes ||= codes_to_keys.keys
      uri = URI.parse("http://www.amazon.com/ss/customer-reviews/ajax/reviews/get/ref=cm_cr_pr_top_recent")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      file = File.open("styles.txt", "w")
      codes_to_keys.each do |code, link_url|
        puts "CODE #{code}"
        new_reviews = 0
        #offset = 0
        form_data = {"asin" => code, "reviewerType" => "all_reviews", "filterByStar" => "all_stars",
          "formatType" => "all_formats", "sortBy" => "recent", "count" => 10, "offset" => 0}
        response = next_ajax_response(http, request, form_data)
        status = response.code
        puts "\nSTATUS IS #{status} for #{code}"
        puts "PRODUCT: #{link_url.product.name}"
        next unless status == "200"
        doc = Nokogiri::HTML(response.body)
        unless doc.css('span.review-count-total').first
          puts "NO REVIEWS for #{code}"
          next
        end
        total_reviews = doc.css('span.review-count-total').first.content.scan(/\d+/).first.to_i
        puts "TOTAL REVIEWS #{total_reviews(doc)} for #{code}"
        processed_keys = process_response(doc, http, request, form_data, processed_keys, file, link_url)
        #puts "NEW REVIEWS FOR #{code}: #{new_reviews}"
        puts "PROCESSED KEYS #{processed_keys.count}"
      end
      file.close
      nil
    end

    def normal_page_reviews
      existing_keys = Set.new(AmazonReview.where("review_date >= '2014-12-01'").map(&:unique_key))
      Forum.find(1).product_links.each do |pl|
        pl.link_urls.each do |lu|
          get_reviews_from_page(lu, 1, existing_keys)
        end
      end
      nil
    end

    def get_reviews_from_page(lu, page_number, existing_keys)
      # for the first page, frequently get 503 if pageNumber=1
      # better to only put in pageNumber after the first page
      url = "http://www.amazon.com/#{lu.link}"
      url << "?pageNumber=#{page_number}" if page_number > 1
      begin
          doc = Nokogiri::HTML(open(url))
        rescue => e
          puts "#{e.message} FOR #{url}" if page_number > 1
        end
        return unless doc
        #reviews = doc.css("table#productReviews tr td >  div")
        reviews = doc.css('.review')
        puts "THERE ARE #{reviews.count} REVIEWS ON #{url}"
        return existing_keys
        if reviews.count > 0
            reviews.each do |review|
              text = review.to_s
              if text =~ /<nobr>([A-z]+) (\d{1,2}), (\d{4})/
                month = MONTHS[$1[0..2]]
                day = $2
                day = "0#{day}" if day.length == 1
                year = $3
                next unless year == '2014' && month > 6
              else
                puts "DATE FAILS"; next
              end
              anchor = review.at('a.yesButton')
              if anchor && anchor["href"] =~ /AnchorName=([A-z0-9]+)/
                key = $1
                print '.'
              else
                puts "NO KEY"
              end
              next unless key
              next unless existing_keys.add?(key)
              puts "NEW REVIEW #{key}"
              args = args_from_review(review, lu, day, month, year)
              unless args
                puts "NO ARGS"
                next
              end
              args[:unique_key] = key
              args[:link_url_id] = lu.id
              az = AmazonReview.new(args)
              puts args.inspect
              puts "REVIEW IS VALID #{az.valid?}"
              az.save! if az.valid?
            end
          end
        if doc.to_s =~ /href=([^>]+)>Next/
          puts "GETTING NEXT PAGE"
          existing_keys = get_reviews_from_page(lu, page_number+1, existing_keys)
        end
        existing_keys
    end

    def process_response(doc, http, request, form_data, prior_keys, file, link_url)

      #puts doc.to_s

      styles = Set.new
      processed_keys = Set.new(prior_keys)
      reviews = doc.css('.review')
      puts "REVIEW COUNT #{reviews.count}"
      reviews.each do |review|
        rows = review.css('.a-row')
        author_date =  rows[2].content # author and date
        unless author_date =~ /UTC 2014|UTC 2015/
          return processed_keys
        end

        puts "AUTHOR DATE #{author_date}"

        unique_key =  review.attributes['id'].value
        unless processed_keys.add?(unique_key)
          print '.'
          next# I tried break but only got 248 reviews instead of 259
          # some small number of review lists are still not in descending order ?
        end
        puts "UNIQUE KEY #{unique_key}"

        # puts "HERE ARE THE ROWS"
        # rows.each{ |row| puts row.to_s; puts }

        # puts "IS THIS THE HEADLINE?"
        # puts review.css('a.review-title').text

        # puts "IS THIS THE BODY?"
        # puts review.css('span.review-text').text

        rating_str = rows[1].to_s.scan(/a-star-\d/)[0] # rating
        if (rating_str =~ /a-star-(\d)/)
          rating = $1.to_i
        else
          puts "NO RATING"
          next
        end
        puts "\nRATING #{rating}"
        headline =  review.css('a.review-title').text #  rows[1].content # headline
        raise "EMPTY HEADLINE" unless headline.length > 0
        puts "HEADLINE #{headline}"
        puts "AUTHOR / DATE  #{author_date}"
        if author_date =~ /By(.+)on (Mon|Tue|Wed|Thu|Fri|Sat|Sun) (\w\w\w) (\d\d) .+ UTC (\d\d\d\d)/
          author = $1.strip
          month = $3
          day = $4
          year = $5
        else
          puts "NO AUTHOR DATE MATCH"
        end
        review_date = "#{year}-#{month}-#{day}"
        puts "**#{author}**  **#{review_date}**"
        style_elt = rows[3].at_css('span.a-size-mini')
        product_id = link_url.product.id
        if style_elt
          style = style_elt.content.gsub(/<[^>]+>/, '')
          puts "STYLE #{style}"
          styles.add(style)
          if style =~ /Style Name: (.+)/
            if (id = STYLE_PRODUCTS[$1])
              product_id = id
            end
          end
        end
        body = review.css('span.review-text').text
        raise "EMPTY BODY" unless body.length > 0
        #body = rows[3].css('.a-section').map{|s| s.content.strip}.join(' ') # review
        args = {
          unique_key: unique_key,
          review_date: review_date,
          rating: rating,
          headline: headline,
          body: body,
          rating: rating,
          author: author,
          product_id: product_id,
          code: form_data["asin"],
          link_url_id: link_url.id,
          style: style
        }
        r = AmazonReview.new(args)
        valid = r.valid?
        puts "REVIEW VALID: #{valid}"
        r.errors.each{|e| puts e.to_s}#  unless valid
        # p args
        r.save! if valid

      end
      # more = more_reviews(doc)
      # more = 0 # hack for now :-(
      # if (more > 0)
      #   puts "#{more} reviews left"
      #   form_data['offset'] += 10
      #   response = next_ajax_response(http, request, form_data)
      #   doc = Nokogiri::HTML(response.body)
      #   puts doc.to_s
      #   raise
      #   processed_keys = process_response(doc, http, request, form_data, processed_keys, file, link_url)
      # end
      styles.to_a.uniq.each{ |s| file.puts s}
      processed_keys
    end


    def total_reviews(doc)
      doc.css('span.review-count-total').first.content.scan(/\d+/).first.to_i
    end

    def last_showing(doc)
      showing =  doc.css('span.review-count-shown').first.content
      #puts "SHOWING #{showing}"
      if showing =~ /\d+-(\d+)/
        last_showing = $1.to_i
        #puts "LAST SHOWING #{last_showing}"
      else
        raise "NO LAST SHOWING"
      end
      last_showing
    end

    def more_reviews(doc)
      total_reviews(doc) - last_showing(doc)
    end

    def next_ajax_response(http, request, form_data)
      #form_data["offset"] = form_data["offset"] + 10
      # p http
      # p request
      # p form_data
      request.set_form_data(form_data)
      http.request(request)
    end

    def get_all_codes
      codes_to_products = {}
      Forum.find(1).product_links.each do |pl|
        pl.link_urls.each do |lu|
          link = lu.link
          if link =~ /\/([A-Z0-9]+)\z/
            codes_to_products[$1] = lu
          end
        end
      end
      codes_to_products
    end

    def process_styles
      styles = Set.new
      IO.readlines("styles.txt").each do |line|
        styles.add(line.chomp)
      end
      styles.to_a.each{|s| puts s}
      nil
    end

    def list_links_to_products
      file = File.open("links_to_products.tsv", "w")
      product_links = Forum.find(1).product_links.sort_by{ |pl| pl.product.name }
      root = Forum.find(1).root
      product_links.each do |pl|
        name = pl.product.name
        pl.link_urls.each do |lu|
          file.puts "#{name}\t#{root}#{lu.link}"
        end
      end
      file.close
      nil
    end

    def az_experiment
      #url = "http://www.amazon.com/321-Series-Home-Entertainment-System/product-reviews/B001DOHYS8/ref=cm_cr_pr_top_recent/178-0894090-1477506?ie=UTF8&pageNumber=1&showViewpoints=0&sortBy=bySubmissionDateDescending"
      url = "http://www.amazon.com/321-Series-Home-Entertainment-System/product-reviews/B001DOHYS8/ref=cm_cr_pr_top_recent?ie=UTF8&showViewpoints=0&sortBy=bySubmissionDateDescending"
      doc = Nokogiri::HTML(open(url))
      puts doc.to_s
    end



    def count_reviews_by_link
      ActiveRecord::Base.logger.level = 1
      counts = Hash.new(0)
      Forum.find(1).product_links.each do |pl|
        pl.link_urls.each do |lu|
          count =  lu.reviews.where("review_date > '2014-01-01'").count
          name = lu.product_link.product.name
          puts "#{count} #{lu.product_link.product.name}" if count < 10
          counts[name] += count
        end

      end
      counts.sort_by{ |k,v| -v}.each{ |name, count| puts "#{name} => #{count}" }
      nil
    end

  end # self

end


# http://www.amazon.com/Bose-SoundTouch-Series-Wireless-System/product-reviews/B00NGK897M/ref=cm_cr_pr_btm_link_1?ie=UTF8&showViewpoints=1&sortBy=recent&reviewerType=all_reviews&formatType=all_formats&filterByStar=all_stars&pageNumber=1
# http://www.amazon.com/Bose-SoundTouch-Series-Wireless-System/product-reviews/B00NGK897M/ref=cm_cr_pr_btm_link_next_2?ie=UTF8&showViewpoints=1&sortBy=recent&reviewerType=all_reviews&formatType=all_formats&filterByStar=all_stars&pageNumber=2
# http://www.amazon.com/Bose-SoundTouch-Series-Wireless-System/product-reviews/B00NGK897M/ref=cm_cr_pr_btm_link_next_3?ie=UTF8&showViewpoints=1&sortBy=recent&reviewerType=all_reviews&formatType=all_formats&filterByStar=all_stars&pageNumber=3
# first 20 codes ["B001DOHYS8", "B00356PVLE", "B001DE4D5U", "B001DP9002", "B001DPB1XG", "B000GFPTQY", "B00022RV6C", "B008RQG1BG", "B00006WNKQ", "B00006J054", "B00GQ0R64Q", "B00006J055", "B00006L7RT", "B00006L7RV", "B00006L7RW", "B000A0HFKI", "B00011CNWG", "B000HWV8QG", "B0091EBU28", "B007ZDEAT2", "B00478O0JI"]
