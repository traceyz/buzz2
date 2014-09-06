class CnetScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("Cnet")
    end


    def page_reviews(doc)
      doc.css(".rateSum")
    end

    def get_unique_key(review)
      review.attr("messageid")
    end

    def args_from_review(review, link_url)
      review_string = review.at_css(".userReviewBody").to_s
      pros = review_string =~ /Pros.?<\/strong>(.+?)<\/p>/sm ? "Pros: #{$1} " : ""
      cons = review_string =~ /Cons.?<\/strong>(.+?)<\/p>/sm ? "Cons: #{$1} " : ""
      summary = review_string =~ /Summary.?<\/strong>(.+?)<\/p>/sm ? $1 : ""
      body = "#{pros}#{cons}#{summary}".gsub(/<[^>]+>/,"")
      begin
        author_elt = review.at_css(".author").text
      rescue
        author_elt = ""
      end
      {
        rating: review.at_css(".stars").text.sub(/stars/,"").strip.to_i,
        headline: review.at_css(".userRevTitle").text.gsub(/\"/, "").strip,
        author: author_elt,
        review_date: build_date(review.at_css("time").text),
        body: body
      }
    end

    def next_link(doc,link_url,url,klass)
      begin
         URI::encode("#{forum.root}#{doc.at_css('li.next a')[:href]}")
      rescue
        puts "NO NEXT LINK"
      end
    end

  end

end
