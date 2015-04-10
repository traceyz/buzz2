class BestBuyScraper < Scraper

  require 'open-uri'
  require 'json'

  class << self

    def forum
      Forum.find_by_name("BestBuy")
    end

    def url_from_link(link_url, idx=1)
      raise "#{link_url.link} FAILS" unless link_url.link =~ /skuId=(\d+)/
      # file = File.open("bb_sku_ids.txt", "a")
      key = $1
      # file.puts key
      # file.close
      root = 'http://bestbuy.ugc.bazaarvoice.com/3545w/'
      tail = '/reviews.djs?format=embeddedhtml&page='
      final = '&scrollToTop=true%20HTTP/1.1'
      "#{root}#{key}#{tail}#{idx}#{final}"
    end

    def doc_from_url(url)
      p = open(url)
      p.read =~ /var materials=({.+}),\s*initializers=/m
      JSON.parse($1)["BVRRSourceID"]
    end

    def page_reviews(doc)
      Nokogiri::HTML(doc).css('div.BVRRContentReview')
    end

    def next_link(doc,link_url,previous_url,klass)
      raise "NEXT LINK FAILS #{link_url}" unless previous_url =~ /page=(\d+)&/
      idx = $1.to_i + 1
      puts "NEXT LINK:   #{$1} #{$1.to_i} #{idx}"
      return nil if idx > 5
      url_from_link(link_url, idx)
    end

    def get_unique_key(review)
      review.attr("id").split("_")[1]
    end

    def args_from_review(review, link_url, day, month, year)
      date_str = review.css('span.BVRRReviewDate').text.strip
      {
        headline: review.css('span.BVRRReviewTitle').text.strip,
        rating: review.css('span.BVRRRatingNumber')[0].text.to_i,
        author: review.css('span.BVRRNickname').text.strip,
        location: review.css('span.BVRRUserLocation').text.strip,
        review_date: build_date3(date_str),
        body: review.css('span.BVRRReviewText').collect{|c| c.text}.join(" ")
      }
    end

    def build_reviews_from_file(file)
      path = "#{Rails.root}/#{file}"
      doc = Nokogiri::HTML(File.open(path))
      build_reviews_from_doc(doc, nil, nil, "BestBuyReview", true, true)
    end

    def get_date(review)
      mo, da, yr = review.at_css('span.BVRRReviewDate').text.split('/')
      [yr.to_i, mo.to_i, da.to_i]
    end

  end

end
