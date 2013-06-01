class FutureShopScraper < Scraper

  def self.forum
    Forum.find_by_name("FutureShop")
  end

  def self.page_reviews(doc)
    doc.css(".customer-review-item")
  end

  def self.get_unique_key(review)
    # future shop does not have a unique reviewer identifier on the page
    build_unique_key(args_from_review(review))
  end

  def self.args_from_review(review)
    date = review.at_css(".date").text.strip
    if date =~ /(\d+) days ago/
      d = Time.now - ($1.to_i * 60 * 60 * 24)
      review_date = build_date4("#{d.year}-#{d.month}-#{d.day}")
    else
      review_date = build_date(date.strip)
    end
    {
      rating: review.at_css(".rating-score").text.to_i,
      review_date: review_date,
      headline: review.at_css(".customer-review-title").text.strip,
      author: review.at_css(".name").text.strip,
      location: review.at_css(".loc").text.strip.sub(/from /,''),
      body: review.at_css("p").text.strip

    }
  end

  def self.next_link(doc,link_url,url,klass)

  end
end
