class BbLinkScraper < ActiveRecord::Base

 require 'open-uri'

 LINKS = [
  "http://www.bestbuy.com/site/Bose/Bose-Home-Theater-Systems/pcmcat168900050015.c?id=pcmcat168900050015",
  "http://www.bestbuy.com/site/Bose/Bose-iPod-MP3-Accessories/pcmcat169800050010.c?id=pcmcat169800050010",
  "http://www.bestbuy.com/site/Bose/Bose-iPod-MP3-Accessories/pcmcat169800050010.c?id=pcmcat169800050010&gf=y&cp=2",
  "http://www.bestbuy.com/site/Bose/Bose-Headphones/pcmcat168900050019.c?id=pcmcat168900050019",
  "http://www.bestbuy.com/site/Bose/Bose-Headphones/pcmcat168900050019.c?id=pcmcat168900050019&gf=y&cp=2",
  "http://www.bestbuy.com/site/Bose/Mobile-Solutions/pcmcat229700050016.c?id=pcmcat229700050016",
  "http://www.bestbuy.com/site/Bose/Bose-Bluetooth-Accessories/pcmcat280100050016.c?id=pcmcat280100050016",
  "http://www.bestbuy.com/site/Bose/Bose-Computer-Accessories/pcmcat280100050018.c?id=pcmcat280100050018",
  "http://www.bestbuy.com/site/Bose/Bose-Speakers/pcmcat168900050016.c?id=pcmcat168900050016",
  "http://www.bestbuy.com/site/Bose/Bose-Speakers/pcmcat168900050016.c?id=pcmcat168900050016&gf=y&cp=2"
 ]

 class << self

  def hello
    puts "Hello"
  end

  def get_links
    all_links = Set.new
    LINKS.each do |link|
      doc = Nokogiri::HTML(open(link))
      doc.css('a').each do |anchor|
        link = anchor[:href]
        next unless link =~ /tabbed-customerreviews/
        link.sub!(/\/site\//,'')
        link.sub!(/#tabbed-customerreviews/,'')
        next if link =~ /Remote|Charger|Bag|10+Bluetooth+Dock/
        all_links.add(link)
      end
    end
    all_links.to_a.each do |k|
      prod_link = "http://www.bestbuy.com/site/#{k}"
      doc = Nokogiri::HTML(open(prod_link))
      title = doc.at_css('title').to_s.chomp
      if title =~ /<title>([^<]+)</
        puts "#{k}"
        puts $1
      else
        puts "**#{title}**"
      end
      puts
    end
    nil
  end

end

end
