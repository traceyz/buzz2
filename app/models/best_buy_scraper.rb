class BestBuyScraper < Scraper

  require 'open-uri'
  require 'json'

  # this gets reviews from the first page
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

  def self.parse_bb
    file = File.read("#{Rails.root}/lib/load_data/parse_bb.txt")
    json = JSON.parse(File.read("#{Rails.root}/lib/load_data/parse_bb.txt"))
    doc = Nokogiri::HTML(json['BVRRSourceID'])
    doc.css('div.BVRRContentReview').each do |review|
      puts "REVIEW"
    end


  end

  def self.harvest_reviews
    reviews = Set.new
    root = 'http://bestbuy.ugc.bazaarvoice.com/3545w/'
    tail = '/reviews.djs?format=embeddedhtml&page='
    final = '&scrollToTop=true%20HTTP/1.1'
    forum = Forum.find_by_name("BestBuy")
    forum.product_links.each do |product_link|
      product_link.link_urls.each do |link_url|
        idx = 1
        link_url.link =~ /skuId=(\d+)&id/
        next unless $1
        key = $1
        more = true
        while more
          url = root + key + tail + idx.to_s + final
          puts url
          p = open(url)
          p.read =~ /var materials=({.+}),\s*initializers=/m
          json = JSON.parse($1)
          doc = Nokogiri::HTML(json['BVRRSourceID'])
          doc.css('div.BVRRContentReview').each do |review|
            r_id = review.attr("id").split("_")[1]
            puts r_id
            more = reviews.add?(r_id)
            break unless more
          end
          idx += 1
        end
      end
    end
    nil
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
