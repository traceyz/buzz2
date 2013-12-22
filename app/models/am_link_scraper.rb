class AmLinkScraper < ActiveRecord::Base

  require 'open-uri'

  class << self

  LINK = "http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Daps&field-keywords=bose"
  LINK2 = "http://www.amazon.com/s/ref=sr_nr_i_0_br?rh=k%3Abose%2Ci%3Aelectronics&keywords=bose"

  def hello
    puts "Hello"
  end

  def get_links
    get_links_from_link(LINK)
    get_links_from_link(LINK2)
  end

  def get_links_from_link(link)
    links = Set.new
    doc = Nokogiri::HTML(open(link))
    doc.css('.asinReviewsSummary a').each do |href|
      href = href[:href]
      href =~ /www.amazon.com\/(.+)\Z/
      link = $1
      puts "NO LINK FOR #{href}" unless link
      next unless link =~ /Bose|SoundDock|QuietComfort|Wave|SoundLink|Acoustimass|CineMate/
      next if link =~ /Cable-Mini|ToneMatch|SA-2|PM-1|USB-Cable|Panaray|EAG-Portable|PackLite|TosLink|USB-SoundWave|PM-1|VS2|Equalizer|SA-3|Aviation|Eargels|Clothing-Clip|Discontinued|Factory-renewed|power|center-channel|center channel|Miguel-Bose|Replacement-tips|UTS|Connection-Cable|Carrying-case|audio-cable|kit|CD-Changer|Bracket|Connector|charger|Adapter|Battery|travel-bag|Stand|Antenna|remote|Replacement|windscreen|carrying|iteck|cablejive|tips|extension|pedestal|wall-mount|portable-array|kit|B00D42AESY|B000Q2ZKSO|B00E657DAA|B009WNR13U|B008XJZY1A|B00DUMC3XC|B008XJZZ9G|B005CSPHYY|B005KM0KXK|B005KM1GT2|B005KM0RZG|Audio-Engine|Ear-Cushion|B005KM2056|B001AEBZOA|B0015FZVRQ|B001TM9VDK|Bass-Module|Digital-Control|Einstein|-L1-|Ear-Pads|RC18T1-27|B00A2XUDWU|Mobile-Bi-fold-Cover-Leather|B0009JAQHE/i
      links.add(link) unless LinkUrl.where(:link => link).first
    end

    links.each do |lk|
      dc = Nokogiri::HTML(open("http://www.amazon.com/#{lk}"))
      title = dc.at_css('title').to_s.chomp
      next if title =~ /AR1|Rough In Kit|Repair Kit|Foam Edge|Earbuds|Eargels|AL8|Clothing Clip|Non-Bose|Brackets|Upgrade kit|Onkyo|Travel Bag|Link A Cable|Sassy|Charger/i
      puts lk
      puts dc.at_css('title')
    end
    next_link = doc.css('a#pagnNextLink')[0]
    get_links_from_link(next_link[:href]) if next_link
  end

end

end
