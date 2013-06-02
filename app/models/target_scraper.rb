class TargetScraper < Scraper

  class << self

    def forum
      Forum.find_by_name("Target")
    end

    def page_reviews(doc)

    end

    def get_unique_key(review)

    end

    def args_from_review(review)
      {

      }
    end

    def next_link((doc,link_url,url,klass)

    end

  end

end
