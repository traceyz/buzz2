class FutureShopScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("FutureShop")
    end

    def page_reviews(doc)
      reviews = doc.css(".customer-review-item")
      puts "REVIEWS COUNT #{reviews.count}"
      reviews
    end

    def get_unique_key(review)
      # future shop does not have a unique reviewer identifier on the page
      year, month, day = get_date(review)
      args = {
        :rating => review.at_css(".rating-score").text.to_i,
        :review_date => "#{year}-#{month}-#{day}",
        :headline => review.at_css(".customer-review-title").text.strip,
        :author => review.at_css(".name").text.strip,
        :location => review.at_css(".loc").text.strip.sub(/from /,''),
        :body => review.at_css("p").text.strip,
      }
      build_unique_key(args)
    end

    def get_date(review)
      str = review.at_css(".date").text.strip
      month_str, day, year = str.split
      day = day.sub(/,/,'').to_i
      month = MONTHS[month_str]
      [year.to_i, month, day.to_i]
    end

    def args_from_review(review, link_url, day, month, year)
      # date = review.at_css(".date").text.strip
      # if date =~ /(\d+) days ago/
      #   d = Time.now - ($1.to_i * 60 * 60 * 24)
      #   review_date = build_date4("#{d.year}-#{d.month}-#{d.day}")
      # else
      #   review_date = build_date(date.strip)
      # end
      {
        rating: review.at_css(".rating-score").text.to_i,
        review_date: "#{year}-#{month}-#{day}",
        headline: review.at_css(".customer-review-title").text.strip,
        author: review.at_css(".name").text.strip,
        location: review.at_css(".loc").text.strip.sub(/from /,''),
        body: review.at_css("p").text.strip

      }
    end

    def next_link(doc,link_url,url,klass)

    end

  end

end
