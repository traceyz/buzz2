class BestBuyScraper < Scraper

  require 'open-uri'
  require 'json'

  @@forum = Forum.find_by_name("BestBuy")

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

  def self.reviews_page_link(args)
    key = args[:key] || ""
    idx = args[:idx] || ""
    root = 'http://bestbuy.ugc.bazaarvoice.com/3545w/'
    tail = '/reviews.djs?format=embeddedhtml&page='
    final = '&scrollToTop=true%20HTTP/1.1'
    "#{root}#{key}#{tail}#{idx}#{final}"
  end

  def self.reviews_from_doc(args)
    doc = args[:doc]
    link_url = ags[:link_url]
    klass = args[:klass]
    limit = args.fetch(:klass,0)
  end

  def self.harvest_reviews
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
          url = "#{root}#{key}#{tail}#{idx}#{final}"
          p = open(url)
          p.read =~ /var materials=({.+}),\s*initializers=/m
          json = JSON.parse($1)
          doc = Nokogiri::HTML(json['BVRRSourceID'])
          doc.css('div.BVRRContentReview').each do |review|
            args = {:unique_key => get_unique_key(review), :link_url_id => link_url.id}
            if BestBuyReview.where(:unique_key => args[:unique_key]).first
              puts "Review already exists"
              more = true
              break
            end
            add_args = args_from_review(review)
            next unless add_args
            args.update(unescape(add_args))
          end
          idx += 1
        end
      end
    end
    nil
  end

  def self.next_link(doc,previous_link)

  end

  def self.unique_key(review)
    review.attr("id").split("_")[1]
  end

  def self.page_reviews(doc)
    reviews = doc.css('#BVRRContainer').text
    reviews.sub!(/\A\s*\(\d+ out of \d+\)/,'')
    reviews.split("Was this review helpful?")
  end


  def self.args_from_review(review)
    date = review.css('span.BVRRReviewDate').text.strip
    {
      :headline => review.css('span.BVRRReviewTitle').text.strip,
      :rating => review.css('span.BVRRRatingNumber')[0].text.to_i,
      :author => review.css('span.BVRRNickname').text.strip,
      :location => review.css('span.BVRRUserLocation').text.strip,
      :review_date => build_date3(date),
      :body => review.css('span.BVRRReviewText').collect{|c| c.text}.join(" ")
    }
  end

  def self.next_link(doc)
    "NOT KNOWN"
  end

end
