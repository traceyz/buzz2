class AppleScraper < Scraper

  def self.harvest_reviews
    get_reviews(Forum.find_by_name("Apple"))
  end

  def self.page_reviews(doc)
    doc.css('.review')
  end

  def self.get_unique_key(review)
    review.css('input[name="voteId"]').attr("value").text
  end

  def self.args_from_review(review)
    args = {}
    args[:rating] = review.css('span[@itemprop="ratingValue"]').text.to_i
    args[:headline] = review.css('h2.summary').text.strip
    args[:author] = review.css('span[@itemprop="author"]').text
    str = review.css('ul.statistics > li').first.text.strip
    args[:location] = str =~ /.+from (.+)\Z/ ? $1 : "NA"
    date_str = review.css('time').attr('datetime').text
    args[:review_date] = build_date4(date_str)
    args[:body] = review.css('p.description').text.strip
    args
  end

  def self.next_link(doc)
    "NOT KNOWN"
  end

end
