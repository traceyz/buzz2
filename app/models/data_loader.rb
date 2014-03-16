class DataLoader < ActiveRecord::Base
  A = Forum.where(:name => "Amazon").first
  AP = Forum.where(:name => "Apple").first
  BB = Forum.where(:name => "BestBuy").first

  def self.build_link(forum, product, title, link)
    #puts "PRODUCT ID IS #{product.id}"
    product_link = forum.product_links.create!(:product_id => product.id, :active => true)
    product_link.link_urls.create!(:link => link, :title => title, :current => true)
    nil
  end

  def self.am_oct_26
    c = Category.where(:name => "Wi-Fi Music Systems").first
    stp = c.products.create!(:name => "SoundTouch Portable")
    link = "Bose-SoundTouch-Portable-Wi-Fi-System/product-reviews/B00FF1VCW4"
    title = "Bose SoundTouch Portable Wi-Fi Music System"
    build_link(A, stp, title, link)
    st20 = c.products.create!(:name => "SoundTouch 20")
    link = "Bose-SoundTouch-Wi-Fi-Music-System/product-reviews/B00FF1VCVK"
    title = "Bose SoundTouch 20 Wi-Fi Music System"
    build_link(A, st20, title, link)
    st30 = c.products.create!(:name => "SoundTouch 30")
    link = "Bose-SoundTouch-Wi-Fi-Music-System/product-reviews/B00FF1VCSI"
    title = "Bose SoundTouch 30 Wi-Fi Music System"
    build_link(A, st30, title, link)
    c = Category.where(:name => "Headphones").first
    oe = c.products.create!(:name => "OE")
    link = "Bose-BOSE-OE-OE-Audio-Headphones/product-reviews/B0081X1R8C"
    title = "Bose OE Audio Headphones"
    build_link(A, oe, title, link)
  end

  def self.ap_oct_25
    qc20 = Product.where(:name => "QC 20").first
    title = "Bose QuietComfort 20i Acoustic Noise Cancelling Headphones"
    link = "/us/reviews/HB764VC/A/bose-quietcomfort-20i-acoustic-noise-cancelling-headphones"
    build_link(AP, qc20, title, link)
    stp20 = Product.where(:name => "SoundTouch 20").first
    title = "Bose SoundTouch 20 Wi-Fi Music System"
    link = "/us/reviews/HD475VC/A/bose-soundtouch-20-wi-fi-music-system"
  end

  def self.am_nov_10
    product = Product.where(:name => "191").first
    title = "Bose Virtually Invisible 191 speakers"
    link = "Bose-Virtually-Invisible-speakers-Pair/product-reviews/B00009P2YQ"
    build_link(A,product,title,link)
    product = Product.where(:name => "SoundLink Mini").first
    title = "Bose SoundLink Mini Bluetooth Wireless Speaker and Soft Orange Cover Bundle"
    link = "Bose-SoundLink-Bluetooth-Wireless-Speaker/product-reviews/B00EJM5P5K"
    build_link(A,product,title,link)
    title = "Bose SoundLink Mini Bluetooth Wireless Speaker and Soft Blue Cover Bundle"
    link = "Bose-SoundLink-Bluetooth-Wireless-Speaker/product-reviews/B00F5IMTPG"
    build_link(A,product,title,link)
    product = Product.where(:name => "Jewel Cube Speakers").first
    title = "Bose Premium Jewel Cube Speaker (Black)"
    link = "Bose-Premium-Jewel-Speaker-Black/product-reviews/B005NP5CMI"
    build_link(A,product,title,link)
    product = Product.where(:name => "Wave music system").first
    title = "Wave Music System III Premium Bundle - Platinum White"
    link = "Wave%C2%AE-Music-System-Premium-Bundle/product-reviews/B009LJ8VVQ"
    build_link(A,product,title,link)
  end

  def self.new_categories
    Category.update_all(:position => 100)
    loud = Category.create!(:name => "Loudspeakers", :position => 7)
    life = Category.create!(:name => "Lifestyle", :position => 3)
    bt = Category.create!(:name => "Bluetooth Speakers", :position => 8)
    ip = Category.create!(:name => "iPod Speakers", :position => 9)
    cp = Category.create!(:name => "Computer Speakers", :position => 10)
    vw = Category.where(:name => "Video Systems").first
    vw.update_attributes!(:name => "VideoWave", :position => 4)
    wav = Category.where(:name => "Wave Products").first
    wav.update_attributes!(:name => "Wave", :position => 6)
    Category.where(:name => "TV Speakers").first.update_attributes(:position => 1)
    Category.where(:name => "Home Theater Speakers").first.update_attributes(:position => 2)
    Category.where(:name => "Wi-Fi Music Systems").first.update_attributes(:position => 5)
    Category.where(:name => "Headphones").first.update_attributes(:position => 11)
  end

  def self.new_products
    cat = Category.where(:name => "Wi-Fi Music Systems").first
    cat.products.create!(:name => "SoundTouch Controller")
    cat.products.create!(:name => "SoundTouch Stereo JC Wi-Fi")
    cat.products.create!(:name => "SoundTouch SA-4 Amplifier")
    cat = Category.where(:name => "Lifestyle").first
    [
      "Lifestyle 535 Series II",
      "Lifestyle 525 Series II",
      "Lifestyle 520",
      "Lifestyle 510",
      "Lifestyle 235 Series II",
      "Lifestyle 135 Series II"
    ].each{|n| cat.products.create!(:name => n)}
    Category.where(:name => "Wave").first.products.create!(:name => "VideoWave III")
    Category.where(:name => "Wave").first.products.create!(:name => "Wave SoundTouch Music System")

  end

  def self.am_11_24
    product = Product.find(114) # Lifestyle 525 Series II
    link = "Bose-Lifestyle-Series-Entertainment-System/product-reviews/B00FGLTYFK"
    title = "Bose Lifestyle 525 Series II Home Entertainment System"
    build_link(A,product,title,link)
    product = Product.where(:name => "SoundLink Bluetooth").first
    link = "Bose-SoundLink-Bluetooth-Wireless-Speaker/product-reviews/B00EE95UDU"
    title = "Bose SoundLink Mini Bluetooth Wireless Speaker and Soft Green Cover Bundle"
    build_link(A,product,title,link)
  end

  def self.ap_11_24
    product = Product.where(:name => "SoundTouch 30").first
    link = "/us/reviews/HD476VC/A/bose-soundtouch-30-wi-fi-music-system"
    title = "Bose SoundTouch 30 WiFi Music System"
    build_link(AP,product,title,link)
  end

  def self.am_12_8
    product = Product.where(:name => "SoundDock III").first
    link = "Bose-SoundDock-Series-Speaker-Limited-Edition/product-reviews/B00FSB696K"
    title = "SoundDock Series III Speaker - Limited-Edition Blue"
    build_link(A,product,title,link)
    link = "Bose-SoundDock-Series-Speaker-Limited-Edition/product-reviews/B00FSB695Q"
    title = "SoundDock Series III Speaker - Limited-Edition Purple"
    build_link(A,product,title,link)
    product = Product.where(:name => "SoundLink Mini Covers").first
    link = "SoundLink%C2%AE-Bluetooth%C2%AE-speaker-leather-cover/product-reviews/B00GWNFC9I"
    title = "SoundLink Mini Bluetooth speaker leather cover - Black"
    build_link(A,product,title,link)
  end

  def self.list_products
    Category.order('position ASC, name ASC').each do |cat|
      puts "#{cat.position} #{cat.name}"
      cat.products.each{|p| puts p.name}
      puts
    end
    nil
  end

  def self.am_12_21
    product = Product.where(:name => "SoundLink Mini Covers").first
    link = "Bose-Soft-Cover-SoundLink-Mini/product-reviews/B00GMONZWS"
    title = "Bose Soft Cover for SoundLink Mini - Orange"
    build_link(A,product,title,link)

    product = Product.where(:name => "Lifestyle 535 Series II").first
    link = "Bose-Lifestyle-Series-Entertainment-System/product-reviews/B00FGLTYEG"
    title = "Bose Lifestyle 535 Series II Home Entertainment System"
    build_link(A,product,title,link)

    product = Product.where(:name => "SoundDock III").first
    link = "Bose-SoundDock%C2%AE-Series-speaker-Limited-Edition/product-reviews/B00FSB6B2W"
    title = "Bose SoundDock Series III speaker - Limited-Edition Green"
    build_link(A,product,title,link)
    link = "Bose-SoundDock-Series-Speaker-Limited-Edition/product-reviews/B00FSB6B22"
    title = "Bose SoundDock Series III Speaker - Limited-Edition Orange"
    build_link(A,product,title,link)

  end

  def self.am_12_21A
    product = Product.where(:name => "Wave SoundTouch Music System").first
    link = "Bose-Wave-SoundTouch-music-system/product-reviews/B00GR0OFKS"
    title = "Bose Wave SoundTouch music system - Titanium Silver"
    build_link(A,product,title,link)
  end

  def self.am_12_21B
    product = Product.where(:name => "CineMate").first
    link = "CineMate%C2%AE-Digital-Theater-Speaker-Version/product-reviews/B002KY2OU8"
    title = "Bose CineMate Series II Digital Home Theater Speaker System"
    build_link(A,product,title,link)

    link = "Bose%C2%AE-CineMate%C2%AE-Series-Digital-System/product-reviews/B00ANEAJZY"
    title = "Bose CineMate Series II Digital Music System"
    build_link(A,product,title,link)

    product = Product.where(:name => "SoundDock").first
    link = "Bose-Sounddock-Series-Digital-System/product-reviews/B005LWY68E"
    title = "Bose Sounddock Series II Digital Music System for iPod (Black)"
    build_link(A,product,title,link)

    product = Product.where(:name => "321").first
    link = "Bose-3-2-1-Home-Entertainment-System/product-reviews/B0000DJF5S"
    title = "Bose 3-2-1 GS DVD Home Entertainment System"
    build_link(A,product,title,link)

    product = Product.where(:name => "Bose Solo").first
    link = "Bose%C2%AE-Solo-TV-Sound-System/product-reviews/B00DOQ2WNA"
    title = "Bose Solo TV Sound System"
    build_link(A,product,title,link)

    product = Product.where(:name => "Wave Control Pod").first
    link = "Bose-Wave%C2%AE-control-pod/product-reviews/B004C1VX7W"
    title = "Bose Wave control pod"
    build_link(A,product,title,link)

    product = Product.where(:name => "Wave Radio").first
    link = "Bose-351020-0020-Wave%C2%AE-III-dock/product-reviews/B00BZBJJ50"
    title = "Bose Wave III dock"
    build_link(A,product,title,link)

    product = Product.where(:name => "Wave Radio CD").first
    link = "Bose-Radio-Player-White-Color/product-reviews/B00803CXO0"
    title = "Bose Wave Radio/cd Player White in Color"
    build_link(A,product,title,link)

    product = Product.where(:name => "SoundLink Bluetooth").first
    link = "Bose-SoundLink-Bluetooth-Speaker-Wireless/product-reviews/B00EPY9KIU"
    title = "Bose SoundLink Mini Bluetooth Speaker"
    build_link(A,product,title,link)

    product = Product.where(:name => "QC 3").first
    link = "Bose-QuietComfort-Acoustic-Canceling-Headphones/product-reviews/B00EFWBIT6"
    title = "Bose QuietComfort 3 Acoustic Noise Canceling Headphones"
    build_link(A,product,title,link)
  end

  def self.build_bb_link(name, title, link)
    product = Product.where(:name => name).first
    raise "NO PRODUCT FOR **#{name}**" unless product
    build_link(BB, product, title, link)
  end

  def self.bb_links_12_22
    name = "CineMate"
    link = "bose-174-cinemate-174-gs-series-ii-digital-home-theater-speaker-system/9480411.p?skuId=9480411&id=1218112362266"
    title = "Bose CineMate GS Series II Digital Home Theater Speaker System"
    build_bb_link(name, title, link)

    name = "Bose Solo"
    link = "bose-174-solo-tv-sound-system/8753193.p?skuId=8753193&id=1218890195868"
    title = "Bose Solo TV Sound System"
    build_bb_link(name, title, link)

    name = "Cinemate 1 SR"
    link = "bose-174-cinemate-174-1-sr-digital-home-theater-speaker-system/2939159.p?skuId=2939159&id=1218365971467"
    title = "Bose CineMate 1 SR"
    build_bb_link(name, title, link)

    name = "Lifestyle 535 Series II"
    link = "bose-174-lifestyle-174-535-series-ii-home-entertainment-system/1730024.p?skuId=1730024&id=1219062285175"
    title = "Bose Lifestyle 535 Series II Home Entertainment System"
    build_bb_link(name, title, link)

    name = "Lifestyle 525 Series II"
    link = "bose-174-lifestyle-174-525-series-ii-home-entertainment-system/1730015.p?skuId=1730015&id=1219062280591"
    title = "Bose Lifestyle 525 Series II"
    build_bb_link(name, title, link)

    name = "Lifestyle 135 Series II"
    link = "bose-174-lifestyle-174-135-series-ii-home-entertainment-system/1693328.p?skuId=1693328&id=1219060354872"
    title = "Bose Lifestyle 135 Series II Home Entertainment System"
    build_bb_link(name, title, link)

    name = "SoundLink Bluetooth"
    link = "bose-174-soundlink-174-mini-bluetooth-speaker/9154107.p?skuId=9154107&id=1218992518770"
    title = "Bose SoundLink Mini Bluetooth Speaker"
    build_bb_link(name, title, link)

    name = "SoundLink Mini"
    link = "bose-174-soundlink-174-wireless-mobile-speaker-ii-dark-gray/6449688.p?skuId=6449688&id=1218737492901"
    title = "Bose SoundLink Wireless Mobile Speaker II"
    build_bb_link(name, title, link)

    name = "SoundDock III"
    link = "bose-174-sounddock-174-series-iii-digital-music-system/7551221.p?skuId=7551221&id=1218851198658"
    title = "Bose SoundDock Series III Digital Music System"
    build_bb_link(name, title, link)

    name = "SoundLink Mini Covers"
    link = "bose-174-soundlink-174-mini-bluetooth-speaker-soft-cover-blue/9912574.p?skuId=9912574&id=1219043636860"
    title = "Bose SoundLink Mini Bluetooth Speaker Soft Cover Blue"

    name = "SoundLink Mini Covers"
    link = "bose-174-soundlink-174-mini-bluetooth-speaker-soft-cover-green/9910764.p?skuId=9910764&id=1219043636862"
    title = "Bose SoundLink Mini Bluetooth Speaker Soft Cover Green"
    build_bb_link(name, title, link)

    name = "SoundLink Mini Covers"
    link = "bose-174-soundlink-174-mini-bluetooth-speaker-soft-cover-orange/9909768.p?skuId=9909768&id=1219043636859"
    title = "Bose SoundLink Mini Bluetooth Speaker Soft Cover Orange"
    build_bb_link(name, title, link)

    name = "SoundDock Portable"
    link = "bose-174-sounddock-174-portable-digital-music-system-for-apple-174-ipod-174-black/8509438.p?skuId=8509438&id=1186005749503"
    title = "Bose SoundDock Portable Digital Music System for Apple iPod SoundDock Portable Digital Music System"
    build_bb_link(name, title, link)

    name = "SoundDock"
    link = "bose-174-sounddock-174-series-ii-digital-music-system-for-apple-174-ipod-174-white/6292469.p?skuId=6292469&id=1218725894433"
    title = "Bose SoundDock Series II Digital Music System for Apple iPod White"
    build_bb_link(name, title, link)

    name = "SoundLink Bluetooth"
    link = "bose-174-soundlink-174-bluetooth-mobile-speaker-ii-white/8834792.p?skuId=8834792&id=1218911492090"
    title = "Bose SoundLink Bluetooth Mobile Speaker II White Leather"
    build_bb_link(name, title, link)

    name = "SoundLink Bluetooth"
    link = "bose-174-soundlink-174-bluetooth-mobile-speaker-ii-black-pink/8826757.p?skuId=8826757&id=1218909521416"
    title = "Bose SoundLink Bluetooth Mobile Speaker II Black Leather Pink"
    build_bb_link(name, title, link)

    name = "SoundLink Bluetooth"
    link = "bose-174-soundlink-174-bluetooth-mobile-speaker-ii-tan-turquoise/8826587.p?skuId=8826587&id=1218910869119"
    title = "Bose SoundLink Bluetooth Mobile Speaker Leather"
    build_bb_link(name, title, link)

    name = "SoundLink Air"
    link = "bose-174-soundlink-174-air-wireless-speaker-for-select-apple-174-devices-black/6238349.p?skuId=6238349&id=1218723190099"
    title = "Bose SoundLink Air Wireless Speaker for Select Apple Devices"
    build_bb_link(name, title, link)

    name = "SoundDock 10"
    link = "bose-174-sounddock-174-10-bluetooth-digital-music-system-for-apple-174-ipod-174-silver/6449697.p?skuId=6449697&id=1218737496015"
    title = "Bose SoundDock 10 Bluetooth Digital Music System for Apple iPod"
    build_bb_link(name, title, link)

    name = "SoundLink Bluetooth"
    link = "bose-174-soundlink-174-wireless-mobile-speaker-ii-silver/6449724.p?skuId=6449724&id=1218737493430"
    title = "Bose SoundLink Wireless Mobile Speaker II Brown"
    build_bb_link(name, title, link)

    name = "SoundDock 10"
    link = "bose-174-sounddock-174-10-bluetooth-dock/9509677.p?skuId=9509677&id=1218116541195"
    title = "Bose SoundDock 10 Bluetooth Dock"
    build_bb_link(name, title, link)

    name = "QC 15"
    link = "bose-174-quietcomfort-174-15-acoustic-noise-cancelling-174-headphones/9450578.p?skuId=9450578&id=1218106625357"
    title = "Bose QuietComfort 15 Acoustic Noise Cancelling Headphones"
    build_bb_link(name, title, link)

    name = "AE2"
    link = "bose-174-ae2-audio-headphones-black/1117121.p?skuId=1117121&id=1218222410544"
    title = "Bose AE2 Audio Headphones"
    build_bb_link(name, title, link)

    name = "IE2"
    link = "bose-174-ie2-earbud-headphones-black-white/1114791.p?skuId=1114791&id=1218221912874"
    title = "Bose IE2 Headphones"
    build_bb_link(name, title, link)

    name = "QC 20"
    link = "bose-174-quietcomfort-174-20i-acoustic-noise-cancelling-174-earbud-headphones/9154082.p?skuId=9154082&id=1218992521020"
    title = "Bose QuietComfort 20i Acoustic Noise Cancelling Earbud Headphones"
    build_bb_link(name, title, link)

    name = "MIE2"
    link = "bose-174-mie2i-mobile-headset-black-silver/1246325.p?skuId=1246325&id=1218241024821"
    title = "Bose MIE2i mobile headset"
    build_bb_link(name, title, link)

    name = "QC 15"
    link = "bose-174-quietcomfort-174-15-acoustic-noise-cancelling-174-headphones-limited-edition-slate-brown/1945216.p?skuId=1945216&id=1219067715035"
    title = "Bose QuietComfort 15 Acoustic Noise Cancelling Headphones Limited Edition"
    build_bb_link(name, title, link)

    name = "AE2w"
    link = "bose-174-ae2w-bluetooth-headphones/8874374.p?skuId=8874374&id=1218924807689"
    title = "Bose AE2w Bluetooth Headphones"
    build_bb_link(name, title, link)

    name = "OE2"
    link = "bose-174-oe2-audio-headphones-black/3021732.p?skuId=3021732&id=1218372336693"
    title = "Bose OE2 Audio Headphones Black"
    build_bb_link(name, title, link)

    name = "SIE2"
    link = "bose-174-sie2i-sport-earbud-headphones-green/6292539.p?skuId=6292539&id=1218725901627"
    title = "Bose SIE2i Headphones"
    build_bb_link(name, title, link)

    name = "SIE2"
    link = "bose-174-sie2i-sport-earbud-headphones-blue/8835018.p?skuId=8835018&id=1218911496242"
    title = "Bose SIE2i Sport Earbud Headphones Blue"
    build_bb_link(name, title, link)

    name = "AE2"
    link = "bose-174-ae2i-audio-headphones-black/2197034.p?skuId=2197034&id=1218313909189"
    title = "Bose AE2i Headphones"
    build_bb_link(name, title, link)

    name = "QC 3"
    link = "bose-174-quietcomfort-174-3-acoustic-noise-cancelling-174-headphones-silver/9039818.p?skuId=9039818&id=1218019624962"
    title = "Bose Corporation QC3 Headhones"
    build_bb_link(name, title, link)

    name = "AE2"
    link = "bose-174-ae2-audio-headphones-white/6266244.p?skuId=6266244&id=1218725181177"
    title = "Bose AE2 Audio Headphones AE2 White"
    build_bb_link(name, title, link)

    name = "SIE2"
    link = "bose-174-sie2i-sport-earbud-headphones-orange/6292511.p?skuId=6292511&id=1218725903494"
    title = "Bose SIE2i Headphones"
    build_bb_link(name, title, link)

    name = "QC 20"
    link = "bose-174-quietcomfort-174-20-acoustic-noise-cancelling-174-earbud-headphones/9154055.p?skuId=9154055&id=1218992521419"
    title = "Bose QuietComfort 20 Acoustic Noise Cancelling Earbud Headphones"
    build_bb_link(name, title, link)

    name = "MIE2"
    link = "bose-174-mie2-earbud-headphones-black-white/1246316.p?skuId=1246316&id=1218241024954"
    title = "Bose MIE2 Headphones"
    build_bb_link(name, title, link)

    name = "SIE2"
    link = "bose-174-sie2i-sport-earbud-headphones-purple/9364078.p?skuId=9364078&id=1219013413492"
    title = "Bose SIE2i Sport Earbud Headphones Purple"
    build_bb_link(name, title, link)

    name = "OE2"
    link = "bose-174-oe2-audio-headphones-white/3021714.p?skuId=3021714&id=1218372338016"
    title = "Bose OE2 Headphones"
    build_bb_link(name, title, link)

    name = "SIE2"
    link = "bose-174-sie2-sport-earbud-headphones-green/6266299.p?skuId=6266299&id=1218725179959"
    title = "Bose SIE2 Sport Earbud Headphones Green"
    build_bb_link(name, title, link)

    name = "OE2"
    link = "bose-174-oe2i-audio-headphones-black/3021769.p?skuId=3021769&id=1218372338158"
    title = "Bose OE2i Audio Headphones Black"
    build_bb_link(name, title, link)

    name = "OE2"
    link = "bose-174-oe2i-audio-headphones-white/3021741.p?skuId=3021741&id=1218372337448"
    title = "Bose OE2i Audio Headphones White"
    build_bb_link(name, title, link)

    name = "AE2"
    link = "bose-174-ae2i-audio-headphones-white/6612586.p?skuId=6612586&id=1218762299590"
    title = "Bose AE2i Audio Headphones White"
    build_bb_link(name, title, link)

    name = "Bluetooth Headset Series 2"
    link = "bose-174-bluetooth-174-headset-series-2-right-ear/2969131.p?skuId=2969131&id=1218367939478"
    title = "Bose Bluetooth Headset Series 2 Right Ear"
    build_bb_link(name, title, link)

    name = "Bluetooth Headset Series 2"
    link = "bose-174-bluetooth-174-headset-series-2-left-ear/2968539.p?skuId=2968539&id=1218367939336"
    title = "Bose Bluetooth Headset Series 2 Left Ear"
    build_bb_link(name, title, link)

    name = "Companion 2 Series III"
    link = "bose-174-companion-174-2-series-iii-multimedia-speaker-system-2-piece/8864513.p?skuId=8864513&id=1218918122908"
    title = "Bose Companion 2 Series III Multimedia Speaker System"
    build_bb_link(name, title, link)

    name = "Companion 20"
    link = "bose-174-companion-174-20-multimedia-speaker-system-2-piece/2683194.p?skuId=2683194&id=1218345204416"
    title = "Bose Companion 20 Multimedia Speaker System"
    build_bb_link(name, title, link)

    name = "Companion 5"
    link = "bose-174-companion-174-5-multimedia-speaker-system-3-piece/7996403.p?skuId=7996403&id=1155071062436"
    title = "Bose Companion 5 Multimedia Speaker System"
    build_bb_link(name, title, link)

    name = "Computer Music Monitor"
    link = "bose-174-computer-musicmonitor-174-black/4941271.p?skuId=4941271&id=1218580149523"
    title = "Bose Computer MusicMonitor"
    build_bb_link(name, title, link)

    name = "Computer Music Monitor"
    link = "bose-174-computer-musicmonitor-174-silver/4941262.p?skuId=4941262&id=1218580117059"
    title = "Bose Computer MusicMonitor Silver"
    build_bb_link(name, title, link)

    name = "161"
    link = "bose-174-161-153-speaker-system-black/4151394.p?skuId=4151394&id=1051384749690"
    title = "Bose 161 Speaker System"
    build_bb_link(name, title, link)

    name = "301"
    link = "bose-174-301-174-series-v-direct-reflecting-174-speaker-system-black/4746449.p?skuId=4746449&id=1051806235077"
    title = "Bose 301 Series V DirectReflecting Speaker System"
    build_bb_link(name, title, link)

    name = "201"
    link = "bose-174-201-174-series-v-direct-reflecting-174-speaker-system-black/4746225.p?skuId=4746225&id=1051806234629"
    title = "Bose 201 Series V DirectReflecting Speaker System"
    build_bb_link(name, title, link)

    name = "251"
    link = "bose-174-151-174-se-environmental-speakers-pair-white/6340907.p?skuId=6340907&id=1076628385961"
    title = "Bose 151 SE Environmental Speakers"
    build_bb_link(name, title, link)

    name = "191"
    link = "bose-174-virtually-invisible-174-191-speakers-pair/5402441.p?skuId=5402441&id=1051826210458"
    title = "Bose Virtually Invisible 191 Speakers"
    build_bb_link(name, title, link)

    name = "151"
    link = "bose-174-151-174-se-environmental-speakers-pair-black/6355632.p?skuId=6355632&id=1076628694828"
    title = "Bose 151 SE Environmental Speakers"
    build_bb_link(name, title, link)

    name = "251"
    link = "bose-174-251-174-environmental-speakers-pair-white/3887510.p?skuId=3887510&id=1051384599811"
    title = "Bose 251 Environmental Speakers"
    build_bb_link(name, title, link)

    name = "791"
    link = "bose-174-virtually-invisible-174-791-in-ceiling-speakers-pair/9570118.p?skuId=9570118&id=1218126041624"
    title = "Bose Virtually Invisible 791 InCeiling Speakers"
    build_bb_link(name, title, link)

    name = "FS 51"
    link = "bose-174-freespace-174-51-landscape-speaker-pair-green/5674941.p?skuId=5674941&id=1055388008634"
    title = "Bose Free Space 51 Outdoor Speakers"
    build_bb_link(name, title, link)

    name = "161"
    link = "bose-174-161-153-speaker-system-white/4337444.p?skuId=4337444&id=1051384816544"
    title = "Bose 161 Speaker System 161 White"
    build_bb_link(name, title, link)

    name = "251"
    link = "bose-174-251-174-environmental-speakers-pair-black/4299636.p?skuId=4299636&id=1051384804692"
    title = "Bose 251 Environmental Speakers"
    build_bb_link(name, title, link)
  end

  def self.bb_2_15
    name = "SoundLink Bluetooth speaker III"
    link = "soundlink-174-bluetooth-speaker-iii/3202003.p?id=1219089114355&skuId=3202003&st=pcmcat169800050010_categoryid$pcmcat310200050004"
    title = "Bose SoundLink Bluetooth Speaker III"
    build_bb_link(name, title, link)
  end

end
