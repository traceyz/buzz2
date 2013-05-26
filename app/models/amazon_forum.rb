class AmazonForum < Forum

  require 'open-uri'
  require 'load_data/utils'

  def self.get_reviews
    forum = Forum.find_by_name("Amazon")
    puts forum.root
    puts forum.tail
    forum.product_links.each do |product_link|
      puts product_link.product.name
      product_link.link_urls.each do |link_url|
        url = forum.root + link_url.link + forum.tail
        puts "URL " + url
        doc = Nokogiri::HTML(open(url))
        puts doc.css('title').text
        reviews_from_page(doc,product_link.product)
        begin
          next_link = doc.css('span.paging')[0].css('a').select{|a| a.text =~ /Next/}.first[:href]
          puts "NEXT LINK " + next_link
        rescue
          puts "NO NEXT LINK"
        end

      end
    end
    nil
  end

def self.reviews_from_page(doc, product_link)
    # forum = Forum.find_by_name("Amazon")
    # product_link = forum.product_links.where(:product_id => product.id).first
    reviews = []
    doc.css("table#productReviews tr td >  div").each do |review|
      args = {}
      begin
        args[:unique_key] = review.css("a[name]")[0][:name].split(".")[0]
      rescue
        # these seem to be comments from the manufacturer
        puts "NO UNIQUE KEY"
        next
      end
      if AmazonReview.where(:unique_key => args[:unique_key]).first
        puts "Review already exists"
        next
      end
      text = review.to_s
      date = text =~ /<nobr>([A-z]+ \d{1,2}, \d{4})/ ? $1 : "FAILS"
      if date.eql?("FAILS")
        puts "DATE FAILS"; next
      end
      args[:product_link_id] = product_link.id
      args[:review_date] = Utils.build_date(date)
      args[:rating] = review.at_css(".swSprite").content.scan(/^\d/)[0].to_i
      body = text.gsub(/<div[^>]+>.+?<\/div>/m,"")
      body.gsub!(/<[^b][^>]+>/m,"")
      body ||= "EMPTY"
      body.gsub!(/<[^>]+>/,"").strip!
      args[:body] = CGI.unescapeHTML(body)
      headline = text =~ /<b>([^<]+)<\/b>/ ? $1 : "EMPTY"
      args[:headline] = CGI.unescapeHTML(headline)
      author = text =~ /By&nbsp\;.+?>([^<]+)<\/span/m ? $1 : "EMPTY"
      args[:author] = CGI.unescapeHTML(author)
      str = text =~ /By&nbsp\;.+?>[^<]+<\/span><\/a>\s(\([^)]+\))/m ? $1 : "NA"
      args[:location] = str.gsub(/[()]/,"")
      reviews << AmazonReview.new(args)
      raise "INVALID" unless reviews[-1].valid?
    end
    reviews
  end
end
