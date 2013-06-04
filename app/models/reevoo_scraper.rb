class ReevooScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("Reevoo")
    end

    def page_reviews(doc)
      doc.css(".review")
    end

    def get_unique_key(review)
      review.at_css("form")[:action].split("/")[2]
    end

    def args_from_review(review)
      attribution = review.at_css(".attribution").text.split(",")
      strengths = review.css(".pros")[1].text.gsub(/\s+/, " ")
      weaknesses = review.css(".cons")[1].text.gsub(/\s+/, " ")
      {
        review_date: build_date2(review.at_css(".date").text),
        author: attribution[0].strip,
        location: attribution[1] ? attribution[1].strip : nil,
        rating: review.at_css(".value").text.to_i,
        body: "Strengths: #{strengths} Weaknesses: #{weaknesses}"
      }
    end

    def next_link(doc,link_url,url,klass)
      begin
        "#{forum.root}#{doc.at_css('a.next_page')[:href]}"
      rescue => e
        puts "NO NEXT LINK #{e.message}"
      end
    end

  end

end
