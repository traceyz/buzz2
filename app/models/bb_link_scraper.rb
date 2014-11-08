class BbLinkScraper < ActiveRecord::Base

 require 'open-uri'

 LINKS = [
  "http://www.bestbuy.com/site/bose/bose-home-theater-systems/pcmcat168900050015.c?id=pcmcat168900050015",
  "http://www.bestbuy.com/site/bose/bose-ipod-mp3-accessories/pcmcat169800050010.c?id=pcmcat169800050010&sp=&gf=y&nrp=25&cp=1",
  "http://www.bestbuy.com/site/bose/bose-ipod-mp3-accessories/pcmcat169800050010.c?id=pcmcat169800050010&gf=y&sp=&nrp=25&cp=2",
  "http://www.bestbuy.com/site/bose/bose-headphones/pcmcat168900050019.c?id=pcmcat168900050019&sp=&gf=y&nrp=25&cp=1",
  "http://www.bestbuy.com/site/bose/bose-headphones/pcmcat168900050019.c?id=pcmcat168900050019&sp=&gf=y&nrp=25&cp=2",
  "http://www.bestbuy.com/site/bose/bose-cell-phone-accessories/pcmcat229700050016.c?id=pcmcat229700050016",
  "http://www.bestbuy.com/site/bose/bose-bluetooth-accessories/pcmcat280100050016.c?id=pcmcat280100050016",
  "http://www.bestbuy.com/site/bose/bose-computer-accessories/pcmcat280100050018.c?id=pcmcat280100050018",
  "http://www.bestbuy.com/site/bose/bose-speakers/pcmcat168900050016.c?id=pcmcat168900050016"
 ]

 class << self

  def get_links
    all_links = Set.new
    LINKS.each do |link|
      doc = Nokogiri::HTML(open(link))
      doc.css('a').each do |anchor|
        link = anchor[:href]
        next unless link =~ /tabbed-customerreviews/
        link.sub!(/\/site\//,'')
        link.sub!(/#tabbed-customerreviews/,'')
        next if link =~ /Remote|Charger|Bag|10+Bluetooth+Dock|floor-stands|carry-case|charging-cradle/
        all_links.add(link)
      end
    end

    skuids = Set.new
    Forum.find(3).product_links.each do |pl|
      pl.link_urls.each do |lu|
        if lu.link =~ /skuId=(\d+)/
          skuids.add($1)
        else
          "NO SKUID"
        end
      end
    end

    all_links.to_a.each do |k|

      if k =~ /skuId=(\d+)/
        skuid = $1
        unless skuids.member?($1)
          puts "http://www.bestbuy.com/site/#{k}#tabbed-customerreviews"
        end
      end
    end
    #   prod_link = "http://www.bestbuy.com/site/#{k}"
    #   doc = Nokogiri::HTML(open(prod_link))
    #   title = doc.at_css('title').to_s.chomp
    #   if title =~ /<title>([^<]+)</
    #     puts $1
    #   else
    #     puts "**#{title}**"
    #   end
    #   puts
    # end
    nil
  end

end

end
