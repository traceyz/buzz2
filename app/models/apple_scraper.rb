class AppleScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("Apple")
    end

    ###############################
    # as of Feb 1, 2015, we have these Apple Store links for Bose Products
    #
    # http://store.apple.com/us/reviews/HF101VC/A/bose-soundlink-bluetooth-speaker-iii?fnode=3f&rs=newest
    # link_url_id 1505
    #
    # http://store.apple.com/us/reviews/HB763VC/A/bose-soundlink-mini-bluetooth-speaker?fnode=3f&page=0&rs=newest
    # link_url_id 429
    #
    # http://store.apple.com/us/reviews/HB764VC/A/bose-quietcomfort-20i-acoustic-noise-cancelling-headphones?fnode=3d&rs=newest
    # link_url_id 457

    def reviews_from_file(link_url_id)
      link_url = LinkUrl.find(link_url_id)
      puts link_url.product_link.product.name
      path ||= "#{Rails.root}/app/models/apple_files/index.html"
      doc = Nokogiri::HTML(open(path))
      reviews = page_reviews(doc)
      puts reviews.count

      reviews.each do |review|
        key = get_unique_key(review)
        puts "UNIQUE KEY ***#{key}***"
        if AppleReview.where(:unique_key => key).first
          puts "Already have review"
          next
        end
        args = unescape(args_from_review(review, link_url))
        args[:unique_key] = key
        args[:link_url_id] = link_url.id
        AppleReview.create!(args)
      end
    end

    def page_reviews(doc)
      doc.css('.review')
    end

    def get_unique_key(review)
      review.css('input[name="voteId"]').attr("value").text
    end

    def args_from_review(review, link_url)
      location_str = review.css('ul.statistics > li').first.text.strip
      date_str = review.css('time').attr('datetime').text
      {
        rating: review.css('span[@itemprop="ratingValue"]').text.to_i,
        headline: review.css('h2.summary').text.strip,
        author: review.css('span[@itemprop="author"]').text,
        location: location_str =~ /.+from (.+)\Z/ ? $1 : nil,
        review_date: build_date4(date_str),
        body: review.css('p.description').text.strip
      }
    end

    def next_link(doc,link_url,url,klass)
      link = nil
      begin
        link =  "#{forum.root}#{doc.css('li.next a')[0][:href]}"
      rescue => e
        puts "NO NEXT LINK"
      end
      link
    end

  end

end
