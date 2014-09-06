class TargetScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("Target")
    end

    def get_target_reviews(link)
      url = "#{Rails.root}/lib/load_data/target.html"
      link = link.sub(/\Ahttp:\/\/www.target.com/,'')
      link_url = LinkUrl.where(:link => link).first
      raise "NO LINK URL FOR #{link}" unless link_url
      doc = doc_from_url(url)
      klass = "TargetReview"
      build_reviews_from_doc(doc,link_url,"",klass,false)
      nil
    end

    def page_reviews(doc)
      doc.css('div.review-srch-list')
    end

    def get_unique_key(review)
      review.at_css('input[id="owner-key"]').attr(:name)
    end

    def args_from_review(review, link_url)
      rating_str = review.at_css('p.ratings-current').text.strip
      rating_str =~ /\d of (\d) stars/
      rating = $1.to_i
      date_str = review.at_css('.review-author').text
      date_str =~ /([A-z]+ \d+, \d+)/
      review_date = build_date($1)
      location_elt = review.at_css('li > span.nameBlue')
      location_str = location_elt.text.strip if location_elt
      location = location_str =~ /from (.+)/ ? $1 : nil
      {
        rating: rating,
        review_date: review_date,
        headline: review.at_css('.review-heading').text.strip,
        author: review.at_css('.review-author span.nameBlue').text,
        location: location,
        body: review.at_css('p.review-text > span').text.strip
      }
    end

    def next_link(doc,link_url,url,klass)
      nil
    end

  end

end
