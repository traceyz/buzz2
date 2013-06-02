class AppleScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("Apple")
    end

    def page_reviews(doc)
      doc.css('.review')
    end

    def get_unique_key(review)
      review.css('input[name="voteId"]').attr("value").text
    end

    def args_from_review(review)
      location_str = review.css('ul.statistics > li').first.text.strip
      date_str = review.css('time').attr('datetime').text
      {
        rating: review.css('span[@itemprop="ratingValue"]').text.to_i,
        headline: review.css('h2.summary').text.strip,
        author: review.css('span[@itemprop="author"]').text,
        location: location_str =~ /.+from (.+)\Z/ ? $1 : "NA",
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
