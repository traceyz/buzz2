class BestBuyScraper < Scraper

  require 'open-uri'
  require 'json'

  class << self

    def self.forum
      Forum.find_by_name("BestBuy")
    end

    def self.url_from_link(link_url, idx=1)
      raise "#{link_url.link} FAILS" unless link_url.link =~ /skuId=(\d+)/
      key = $1
      root = 'http://bestbuy.ugc.bazaarvoice.com/3545w/'
      tail = '/reviews.djs?format=embeddedhtml&page='
      final = '&scrollToTop=true%20HTTP/1.1'
      "#{root}#{key}#{tail}#{idx}#{final}"
    end

    def self.doc_from_url(url)
      p = open(url)
      p.read =~ /var materials=({.+}),\s*initializers=/m
      json = JSON.parse($1)
      Nokogiri::HTML(json['BVRRSourceID'])
    end

    def self.page_reviews(doc)
      doc.css('div.BVRRContentReview')
    end

    def self.next_link(doc,link_url,previous_url,klass)
      raise "NEXT LINK FAILS #{link_url}" unless previous_url =~ /page=(\d+)&/
      idx = $1.to_i + 1
      url_from_link(link_url, idx)
    end

    def self.get_unique_key(review)
      review.attr("id").split("_")[1]
    end

    def self.args_from_review(review)
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

  end

end
