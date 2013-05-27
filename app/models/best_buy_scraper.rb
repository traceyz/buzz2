class BestBuyScraper < Scraper

  def self.eval_reviews
    forum = Forum.find_by_name("BestBuy")
    forum.product_links.each do |product_link|
      product_link.link_urls.each do |link_url|
        url = forum.root + link_url.link + forum.tail
        doc = Nokogiri::HTML(open(url))
        reviews = doc.css('#BVRRContainer').text
        reviews.sub!(/\A\s*\(\d+ out of \d+\)/,'')
        reviews.split("Was this review helpful?").each do |review|
          review.strip!
          review.sub!(/\d+ out of \d+ found this review helpful.\Z/,'')
          headline_rating, content = review.split(/Posted by:/)
          next unless headline_rating
          headline_rating.strip!
          if headline_rating =~ /(.+)(\d)\Z/
            headline = $1
            rating = $2.to_i
          else
            next
          end
          puts headline
          puts rating.to_s
          if content =~ /(.+) from (.*) on (\d\d\/\d\d\/\d\d\d\d)(.+)/
            author = $1
            location = $2
            date_str = $3
            body = $4
          else
            puts "COULD NOT PARSE CONTENT"
            next
          end
          puts "NEXT"
        end
      end
    end
    nil
  end

  def self.harvest_reviews
    get_reviews(Forum.find_by_name("BestBuy"))
  end

  def self.page_reviews(doc)
    reviews = doc.css('#BVRRContainer').text
    reviews.sub!(/\A\s*\(\d+ out of \d+\)/,'')
    reviews.split("Was this review helpful?")
  end

  def self.get_unique_key(review)
    Digest::MD5.hexdigest(review)
  end

  def self.args_from_review(review)

  end

  def self.next_link(doc)
    "NOT KNOWN"
  end

end
