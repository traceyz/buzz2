class AmLinkScraper < ActiveRecord::Base

  require 'open-uri'

  class << self

  LINK = "http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Daps&field-keywords=bose"

  def hello
    puts "Hello"
  end

  def get_links
    file = File.open("am_links_new.txt", "w")
    get_links_from_link(LINK, file)
    file.close
  end

  def get_links_from_link(link, file)
    links = Set.new
    doc = Nokogiri::HTML(open(link))
    doc.css('.asinReviewsSummary a').each do |href|
      href = href[:href]
      href =~ /www.amazon.com\/(.+)\Z/
      link = $1
      raise "NO LINK FOR #{href}" unless link
      next unless link =~ /Bose|SoundDock|QuietComfort|Wave|SoundLink|Acoustimass|CineMate/
      next if link =~ /power|center-channel|center channel|Miguel-Bose|Replacement-tips|UTS|Connection-Cable|Carrying-case|audio-cable|kit|CD-Changer|Bracket|Connector|charger|Adapter|Battery|travel-bag|Stand|Antenna|remote|Replacement|windscreen|carrying|iteck|cablejive|tips|extension|pedestal|wall-mount|portable-array|kit|B00D42AESY|B000Q2ZKSO|B00E657DAA|B009WNR13U|B008XJZY1A|B00DUMC3XC|B008XJZZ9G|B005CSPHYY|B005KM0KXK|B005KM1GT2|B005KM0RZG|Audio-Engine|Ear-Cushion|B005KM2056|B001AEBZOA|B0015FZVRQ|B001TM9VDK|Bass-Module|Digital-Control|Einstein|-L1-|Ear-Pads|RC18T1-27|B00A2XUDWU|Mobile-Bi-fold-Cover-Leather/i
      links.add(link) unless LinkUrl.where(:link => link).first
    end
    #links.each{ |lk|  file.puts "http://www.amazon.com/#{lk}" }
    links.each do |lk|
      dc = Nokogiri::HTML(open("http://www.amazon.com/#{lk}"))
      puts lk
      puts dc.at_css('title')
    end
    next_link = doc.css('a#pagnNextLink')[0]
    get_links_from_link(next_link[:href], file) if next_link
  end

end

end
