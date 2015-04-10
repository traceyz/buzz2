class AmLinkScraper < ActiveRecord::Base

  require 'open-uri'

  class << self

    FORUM = Forum.where(:name => "Amazon").first
    NEW_LINK = "http://www.amazon.com/s/ref=nb_sb_ss_i_0_3?url=search-alias%3Daps&field-keywords=bose&sprefix=bos%2Caps%2C146"

    def build_allowed_codes
      FORUM.product_links.each_with_object(Set.new) do |pl, set|
        # a link is "Bose-Model-Single-Portable-System/product-reviews/B009HUM2IW"
        # we just want B009HUM2IW
        pl.link_urls.each{ |lu| set.add(lu.link.sub(/.+\//,'')) }
      end
    end

    # denied_titles and denied_link_phrases are ways to prune other manufacturers and wierd anomalies
    # we'll mostly use product codes for pruning the actual Bose products
    def denied_titles
      %w(Steez Onkyo Edifier Logitech Sony VicTsing Lightbeats Eupatorium WHARNCLIFFE
        Audio-Technica Senbowe SoundBot FOCUS-Lucia-Bose Sennheiser Kindle Skullcandy
        Beats Fitbit
        CoolStream Tenergy Einstein CableJive Meily ASICS JAM YCC BMR)
    end

    def denied_link_phrases
      %w(Miguel-Bos Rahul-Bose ubhash-chandra-bose Harman-Kardon
        The-Lazy-Desi Buick-Stereo EAG-Iphone SOL-REPUBLIC Non-Retail Empire-CPL)
    end

    def get_new_links
      ActiveRecord::Base.logger.level = 1
      denied_codes = Set.new(FORUM.denied_codes)
      allowed_codes = build_allowed_codes
      get_next_links(NEW_LINK, allowed_codes, denied_codes)
    end

    def get_next_links(link, allowed_codes, denied_codes, seq = 2)
      begin
        doc = Nokogiri::HTML(open(link))
      rescue => e
        puts e.message
        next_link = build_next_link(seq)
        get_next_links(next_link, allowed_codes, denied_codes, seq + 1)
      end
      return "NIL DOC"  unless doc
      links = doc.css('a.s-access-detail-page')
      links.each do |link|
        href = link.attr('href')
        title = link.attr('title')
        next if denied_titles.any?{ |t| title.index(t) }
        next if denied_link_phrases.any?{ |p| href.index(p) }
        next if title =~ /car charger|ButterFox|Ear Pads|Adapter Kit|Shaped Headphones Stand|Skullcandy|BROWNIES|ear cushion kit|Amo|TDK Life|Original Movie Prop/
        next if title =~ /CourseMate|Mullerin|Ultra Egg Sea|Mulligan|PlayStation|StayHear|Aviation|Cosmos|Solitude|Fire|High-Fidelity Ultraslim/
        next if title =~ /Coupling Series 2|BOSE Replacement parts|Sennheiser|Coleccion Definitiva|Mediabridge|Kindle|Plane Quiet|AllConnect|Water Dancing/
        next if title =~ /Replacement|Beats|HQRP|Fitbit|UpBright|Schafe|Tony Bose|Flash Cards|AmazonBasics|Dog Bose Nova|Seismic Audio|Jeevan Mrityu/
        if (href =~ /amazon.com\/(.+)\/dp\/(.+)/)
          pname = $1
          pcode = $2
          next if denied_codes.member?(pcode)
          unless (allowed_codes.member?(pcode))
            puts "\nDO NOT HAVE LINK"
            puts link.attr('href').sub(/http:\/\/www.amazon.com\//,'')
            puts link.attr('title')
          end
        else
          puts "DID NOT FIND NAME / CODE"
        end
      end
      if (doc.at_css('a.pagnNext'))
        next_link = build_next_link(seq)
        get_next_links(next_link, allowed_codes, denied_codes, seq + 1)
      else
        puts "DID NOT FIND NEXT"
      end
      nil
    end

    def build_next_link(seq)
      "http://www.amazon.com/s/ref=sr_pg_#{seq}?rh=i%3Aaps%2Ck%3Abose&page=#{seq}&keywords=bose&ie=UTF8"
    end

    def build_link(product_id, title, link)
      File.open("#{Rails.root}/new_amazon_links_#{Date.today}.txt", 'a') do |f|
        f.puts "\nNew link for: #{Product.find(product_id).name}"
        title =~ /<title>(.+)<\/title>/
        f.puts "Title: #{$1}"
        f.puts "Link: #{FORUM.root + link}"
      end
    end

    def list_links
      File.open("#{Rails.root}/new_amazon_links_#{Date.today}.txt", 'a') do |f|
        f.puts "\nNew link for: #{Product.find(product_id).name}"
        title =~ /<title>(.+)<\/title>/
        f.puts "Title: #{$1}"
        f.puts "Link: #{FORUM.root + link}"
      end
    end
  end # end self

end
