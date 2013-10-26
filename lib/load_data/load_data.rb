module LoadData

  require 'open-uri'

  def load_products
    [
      ["Lifestyle DVD-based Systems",
        ["LS 12", "LS 18", "LS 28", "LS 30", "LS 35", "LS 38", "LS 48"]
      ],
      ["Lifestyle Component-based Systems",
        ["LS 135", "LS 235", "LS T20", "LS V10", "LS V20", "LS V25", "LS V30", "LS V35"]
      ],
      ["321 Systems",
        ["321", "321 GS"]
      ],
      ["Home Theater Speakers",
        ["AM 10", "AM 15", "AM 16", "AM 6", "AM 7", "Acoustimass DirectReflecting Speaker",
        "CineMate", "Cinemate 1 SR", "Jewel Cube Speakers", "VCS 10"]
      ],
      ["TV Speakers",
        ["Bose Solo"]
      ],
      ["Multimedia Speakers",
        ["Companion 2", "Companion 20", "Companion 3", "Companion 5", "Computer Music Monitor",
         "MediaMate", "SoundDock", "SoundDock 10", "SoundDock III", "SoundDock Portable",
         "SoundLink Air", "SoundLink Bluetooth", "Wireless Computer Speaker"]
      ],
      ["Stereo Speakers",
        ["101", "141", "151", "161", "191", "201", "301", "501", "601",
          "6.2", "791", "802", "901", "AM 3", "AM 5"]
      ],
      ["Outdoor Speakers",
        ["131", "251", "FS 51"]
      ],
      ["Wave Products",
        ["AWMS", "Wave Control Pod", "Wave Radio", "Wave Radio CD", "Wave music system"]
      ],
      ["Headphones",
         ["AE2", "AE2w", "Bluetooth Headset", "Bluetooth Headset Series 2",
          "Bose Around-ear", "Bose In-ear", "Bose On-ear", "IE2", "MIE2",
          "Mobile In-Ear Headset", "Mobile On-Ear Headset",
          "OE2", "QC 15", "QC 2", "QC 3", "SIE2"]
      ],
      ["Video Systems",
         ["VideoWave", "VideoWave II-46", "VideoWave II-55"]
      ],
      ["Lifestyle Accessories",
        ["SL2"]
      ]
    ].each do |c_name, p_names|
      puts c_name
      cat = Category.find_by_name(c_name)
      p_names.each { |name| cat.products.create!(:name => name) }
    end
    nil
  end

  def load_forum_links
    data = [
      %w(Amazon am_links.txt),
      %w(Apple ap_links.txt),
      %w(BestBuy bb_links.txt),
      %w(Reevoo bbuk_links.txt),
      %w(Cnet cnet_links.txt),
      %w(FutureShop fs_links.txt),
      %w(NewEgg ne_links.txt)
    ]
    data.each do |forum_name, file_name|
      load_forum(forum_name, file_name)
    end
    nil
  end

  def add_titles_to_links
    input = [
      # %w(Amazon am_links2.txt),
      # %w(Apple ap_links2.txt),
      # %w(BestBuy bb_links2.txt),
      # %w(Reevoo bbuk_links2.txt),
      # %w(Cnet cnet_links2.txt),
      %w(FutureShop fs_links2.txt),
      %w(NewEgg ne_links2.txt)
    ]
    output =  [
      # %w(Amazon am_links.txt),
      # %w(Apple ap_links.txt),
      # %w(BestBuy bb_links.txt),
      # %w(Reevoo bbuk_links.txt),
      # %w(Cnet cnet_links.txt),
      %w(FutureShop fs_links.txt),
      %w(NewEgg ne_links.txt)
    ]
    input.each_with_index do |line, idx|
      forum_name, file_name = line
      forum = Forum.find_by_name(forum_name)
      out_name = output[idx][1]
      out_path = "#{Rails.root}/lib/load_data/#{out_name}"
      out_file = File.open(out_path, 'w')
      read_file(file_name).each do |datum|
        link, product_name = datum.chomp.split(",")
        tail = forum.tail || ""
        url = forum.root + link + tail
        puts url
        begin
          doc = Nokogiri::HTML(open(url))
        rescue => e
          puts e.message
          next
        end
        title = doc.css('title').text.strip.gsub(",",'') # some titles have commas - bad for later split
        out_file.puts "#{link},#{CGI.unescapeHTML(title)},#{product_name}"
      end
      out_file.close
    end
  end

# use this to load the links => products
# recognize that since we aren't using forum product names,
# within a  forum,  there may be multiple links for a product
# - as in different colors
  def read_file(file_name)
    path = "#{Rails.root}/lib/load_data/#{file_name}"
    IO.readlines(path)
  end

  def load_forum(forum_name, file_name)
    coder = HTMLEntities.new
    forum = Forum.find_by_name(forum_name)
    raise "#{forum.name} product links already exist" if forum.product_links.first
    data = read_file(file_name)
    data.each do |datum|
      link, title, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      puts "PRODUCT NAME #{product_name}"
      break unless product_name
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, coder.decode(title.strip), link.strip)
    end
    puts "complete links load for #{forum_name}"
    nil
  end

  def build_link(forum, product, title, link)
    #puts "PRODUCT ID IS #{product.id}"
    product_link = forum.product_links.create!(:product_id => product.id, :active => true)
    product_link.link_urls.create!(:link => link, :title => title, :current => true)
    nil
  end

  def update_am_july_20
    forum = Forum.find_by_name("Amazon")
    product = Product.find_by_name("MIE2")
    link = "Bose-49508-MIE2-Mobile-Headset/product-reviews/B007WQ9LSC"
    title = "Bose MIE2 Mobile Headset"
    build_link(forum, product, title, link)

    product = Product.find_by_name("SIE2")
    link = "Bose-SIE2i-Sport-Headphones-Orange/product-reviews/B00CM6J71I"
    title = "Bose SIE2i Sport Headphones - Orange"
    build_link(forum, product, title, link)
    link = "Bose-SIE2i-Sport-Headphones-Purple/product-reviews/B00CLCMA4O"
    title = "Bose SIE2i Sport Headphones - Purple"
    build_link(forum, product, title, link)

    product = Product.find_by_name("SoundLink Mini")
    link = "Bose-SoundLink-Mini-Bluetooth-Speaker/product-reviews/B00D5Q75RC"
    title = "Bose SoundLink Mini Bluetooth Speaker"
    build_link(forum, product, title, link)

    product = Product.find_by_name("OE2")
    link = "Bose-48780-OE2-audio-headphones/product-reviews/B005KJM30G"
    title = "OE2 audio headphones - Black"
    build_link(forum, product, title, link)

    product = Product.find_by_name("SoundLink Bluetooth")
    link = "Bose-SoundLink-Bluetooth-Mobile-Speaker/product-reviews/B00DE73C5Q"
    title = "Bose SoundLink Bluetooth Mobile Speaker II - Limited Edition White Leather"
    build_link(forum, product, title, link)

    product = Product.find_by_name("Wave Radio")
    link = "Bose-Wave-Radio-Clock-platinum/product-reviews/B00021Y9O0"
    title = "Bose Wave Radio - Clock radio - platinum white"
    build_link(forum, product, title, link)

  end

  def update_bb_july_20
    forum = Forum.find_by_name("BestBuy")
    product = Product.find_by_name("SoundLink Bluetooth")
    link = "Bose%26%23174%3B+-+SoundLink%26%23174%3B+Bluetooth+Mobile+Speaker+II+-+Black/Pink/8826757.p?skuId=8826757&id=1218909521416"
    title = "Bose SoundLink Bluetooth Mobile Speaker II SoundLink BT MBL II Black Leather Pink"
    build_link(forum, product, title, link)
    link = "Bose%26%23174%3B+-+SoundLink%26%23174%3B+Bluetooth+Mobile+Speaker+II+-+Tan/Turquoise/8826587.p?skuId=8826587&id=1218910869119"
    title = "Bose SoundLink Bluetooth Mobile Speaker II SOUNDLINK BT MBL II LEATHER CB"
    build_link(forum, product, title, link)

    product = Product.find_by_name("SoundLink Mini")
    link = "Bose%26%23174%3B+-+SoundLink%26%23174%3B+Mini+Bluetooth+Speaker/9154107.p?skuId=9154107&id=1218992518770"
    title = "Bose SoundLink Mini Bluetooth Speaker SOUNDLINK MINI BLUETOOTH SPEAK"
    build_link(forum, product, title, link)

    product = Product.find_by_name("SIE2")
    link = "Bose%26%23174%3B+-+SIE2+Sport+Earbud+Headphones+-+Green/6266299.p?skuId=6266299&id=1218725179959"
    title = "Bose SIE2 Sport Earbud Headphones SIE2 SPORT HEADPHONE GREEN"
    build_link(forum, product, title, link)
    link = "Bose%26%23174%3B+-+SIE2i+Sport+Earbud+Headphones+-+Purple/9364078.p?skuId=9364078&id=1219013413492"
    title = "Bose SIE2i Sport Earbud Headphones SIE2I SPORT HEADPHONE PURPLE"
    build_link(forum, product, title, link)

    product = Product.find_by_name("OE2")
    link = "Bose%26%23174%3B+-+OE2i+Audio+Headphones+-+White/3021741.p?skuId=3021741&id=1218372337448"
    title = "Bose OE2i Audio Headphones White OE2i HEADPHONES WHT"
    build_link(forum, product, title, link)
    link = "Bose%26%23174%3B+-+OE2i+Audio+Headphones+-+Black/3021769.p?skuId=3021769&id=1218372338158"
    title = "Bose OE2i Audio Headphones Black OE2i HEADPHONES BLK"

    product = Product.find_by_name("Companion 2 Series III")
    link = "Bose%26%23174%3B+-+Companion%26%23174%3B+2+Series+III+Multimedia+Speaker+System+(2-Piece)/8864513.p?skuId=8864513&id=1218918122908"
    title = "Bose Companion 2 Series III Multimedia Speaker System 2Piece COMPANION 2 SERIES III SYSTEM"
    build_link(forum, product, title, link)

    product = Product.find_by_name("Companion 20")
    link = "Bose%26%23174%3B+-+Companion%26%23174%3B+20+Multimedia+Speaker+System+(2-Piece)/2683194.p?skuId=2683194&id=1218345204416"
    title = "Bose Companion 20 Multimedia Speaker System 2Piece COMPANION 20"
    build_link(forum, product, title, link)

    product = Product.find_by_name("Companion 5")
    link = "Bose%26%23174%3B+-+Companion%26%23174%3B+5+Multimedia+Speaker+System+(3-Piece)/7996403.p?skuId=7996403&id=1155071062436"
    title = "Bose Companion 5 Multimedia Speaker System 3Piece COMPANION 5"
    build_link(forum, product, title, link)

    product = Product.find_by_name("Companion 2")
    link = "Bose%26%23174%3B+-+Companion%26%23174%3B+2+Series+II+Multimedia+Speaker+System+(2-Piece)/7933686.p?skuId=7933686&id=1151657980013"
    title = "Bose Companion 2 Series II Multimedia Speaker System 2Piece COMPANION 2 II"
    build_link(forum, product, title, link)


    product = Product.find_by_name("Computer Music Monitor")
    link = "Bose%26%23174%3B+-+Computer+MusicMonitor%26%23174%3B+-+Black/4941271.p?skuId=4941271&id=1218580149523"
    title = "Bose Computer MusicMonitor COMPUTER MUSIC MONITOR BLK"
    build_link(forum, product, title, link)
    link = "Bose%26%23174%3B+-+Computer+MusicMonitor%26%23174%3B+-+Silver/4941262.p?skuId=4941262&id=1218580117059"
    title = "Bose Computer MusicMonitor COMPUTER MUSIC MONITOR SILVER"
    build_link(forum, product, title, link)

    product = Product.find_by_name("FS 51")
    link = "Bose%26%23174%3B+-+FreeSpace%26%23174%3B+51+Landscape+Speaker+(pair)+-+Green/5674941.p?skuId=5674941&id=1055388008634"
    title = "Bose FreeSpace 51 Landscape Speaker"
    build_link(forum, product, title, link)

    product = Product.find_by_name("791")
    link = "Bose%26%23174%3B+-+Virtually+Invisible%AE+791+In-Ceiling+Speakers+(Pair)/9570118.p?skuId=9570118&id=1218126041624"
    title = "Bose Virtually Invisible 791 InCeiling Speakers"
    build_link(forum, product, title, link)

    product = Product.find_by_name("251")
    link = "Bose%26%23174%3B+-+251%26%23174+Environmental+Speakers+(Pair)+-+Black/4299636.p?skuId=4299636&id=1051384804692"
    title = "Bose 251 Environmental Speakers"
    build_link(forum, product, title, link)
    nil
  end

  def update_ap_july_20
    forum = Forum.find_by_name("Apple")
    product = Product.find_by_name("SoundLink Mini")
    link = "/us/reviews/HB763VC/A/bose-soundlink-mini-bluetooth-speaker"
    title = "Bose SoundLink Mini Bluetooth Speaker"
    build_link(forum, product, title, link)

    product = Product.find_by_name("SIE2")
    link = "/us/reviews/HC518ZM/A/bose-sie2i-sport-headphones"
    title = "Bose SIE2i Sport Headphones"
    build_link(forum, product, title, link)

    product = Product.find_by_name("Companion 5")
    link = "/us/reviews/TK760VC/A/bose-companion-5-multimedia-speaker-system"
    title = "Bose Companion 5 Multimedia Speaker System"
    build_link(forum, product, title, link)

    product = Product.find_by_name("AE2w")
    link = "/us/reviews/HC076VC/A/bose-ae2w-bluetooth-headphones"
    title = "Bose AE@w Blustooth Headphones"
    build_link(forum, product, title, link)

    product = Product.find_by_name("OE2")
    link = "/us/reviews/H6784ZM/A/bose-oe2i-audio-headphones"
    title = "Bose OE2i Headphones"
    build_link(forum, product, title, link)

    product = Product.find_by_name("Computer Music Monitor")
    link = "/us/reviews/TX025VC/A/bose%C2%AE-computer-musicmonitor"
    title = "Bose Computer MusicMonitor"
    build_link(forum, product, title, link)

    product = Product.find_by_name("AE2")
    link = "/us/reviews/H9607VC/A/bose-ae2i-mobile-headset-with-remote-and-mic"
    title = "Bose AE2 Mobile Headset"
    build_link(forum, product, title, link)

    product = Product.find_by_name("SoundDock 10")
    link = "/us/reviews/H9850VC/A/bose-sounddock-10-bluetooth-digital-speaker-system"
    title = "Bose SoundDock 10 Bluetooth Digital Music System"
    build_link(forum, product, title, link)
  end

  def update_links
    Forum.find_by_name("Amazon").product_links.where(:product_id => 66).first.link_urls.create!(
      link: "Bose-AE2w-Bluetooth-Headphones-Black/product-reviews/B00CD1FB26",
      title: "Bose AE2w Bluetooth Headphones - Black",
      current: true)
  end

  def update_c3
    forum = Forum.find_by_name("Amazon")
    product = Product.find_by_name("Companion 2 Series III")
    raise "NIL" unless forum && product
    title = "Bose Companion 2 Series III Multimedia Speakers"
    link = "Bose-Companion-Series-Multimedia-Speakers/product-reviews/B00CD1PTF0"
    build_link(forum,product, title, link)
    forum = Forum.find_by_name("BestBuy")
    raise "NIL" unless forum
    title = "Bose Companion 2 Series III Multimedia Speaker System 2Piece COMPANION 2 SERIES III SYSTEM"
    link = "Bose%26%23174%3B+-+Companion%26%23174%3B+2+Series+III+Multimedia+Speaker+System+(2-Piece)/8864513.p?id=1218918122908&skuId=8864513"
    build_link(forum,product, title, link)
  end

  def update_bb_sound_link
    # cat = Category.find_by_name("Multimedia Speakers")
    # product = cat.products.create!(:name => "SoundLink Mini")
    product = Product.find_by_name("SoundLink Mini")
    forum = Forum.find_by_name("BestBuy")
    title = "Bose SoundLink Mini Bluetooth Speaker"
    link = "SoundLink%26%23174%3B+Mini+Bluetooth+Speaker/9154107.p?skuId=9154107&id=1218992518770"
    build_link(forum,product, title, link)
  end

  def update_am_Aug_2
    forum = Forum.find_by_name("Amazon")
    product = Product.find_by_name("QC 20")
    title = "Bose QuietComfort 20 Acoustic Noise Cancelling Headphones"
    link = "Bose-QuietComfort-Acoustic-Cancelling-Headphones/product-reviews/B00D42A16E"
    build_link(forum,product, title, link)
  end

  def am_cover_links
    forum = Forum.find_by_name("Amazon")
    product = Product.find_by_name("SoundLink Mini Covers")
    # title = "SoundDock Portable Cover - Gray"
    # link = "Bose%C2%AE-SoundDock%C2%AE-Portable-Cover-Gray/product-reviews/B008XJZZ9G"

    # title = "SoundDock Portable Cover - Red"
    # link = "Bose%C2%AE-SoundDock%C2%AE-Portable-Cover-Red/product-reviews/B008XJZY1A"

    # title = "SoundLink Wireless Mobile Speaker Cover (Burgundy Leather)"
    # link = "Bose-SoundLink-Wireless-Speaker-Burgundy/product-reviews/B005KM1GT2"

    link = "Bose-Soft-Cover-SoundLink-Mini/product-reviews/B00D42AB50"
    title = "Soft Cover for SoundLink Mini - Blue"
    build_link(forum,product, title, link)

    link = "Bose-Soft-Cover-SoundLink-Mini/product-reviews/B00D42AD4E"
    title = "Soft Cover for SoundLink Mini - Green"
    build_link(forum,product, title, link)

    link = "Bose-Soft-Cover-SoundLink-Mini/product-reviews/B00D42AE2K"
    title = "Soft Cover for SoundLink Mini - Orange"
    build_link(forum,product, title, link)
  end

  def am_links_8_25
    forum = Forum.find_by_name("Amazon")
    product = Product.find_by_name("QC 20")
    title = "Bose QuietComfort 20i Acoustic Noise Cancelling Headphones"
    link = "Bose-QuietComfort-Acoustic-Cancelling-Headphones/product-reviews/B00D429Y12"
    build_link(forum,product, title, link)
  end

  def am_links_8_31
    forum = Forum.find_by_name("Amazon")
    product = Product.where(:name => "MIE2").first
    title = "MIE2i Mobile Headset"
    link = "Bose-326223-0080-Bose%C2%AE-Mobile-Headset/product-reviews/B0043WCH66"
    build_link(forum,product, title, link)
    product = Product.where(:name => "OE2").first
    title = "OE2 Audio Headphones - Black"
    link = "Bose-346018-0010-OE2-audio-headphones/product-reviews/B005KJM30G"
  end

  def am_links_9_13
    forum = Forum.find_by_name("Amazon")
    product = Product.where(:name => "OE2").first
    title = "OE2 Audio Headphones - Black"
    link = "Bose-346018-0010-OE2-audio-headphones/product-reviews/B005KJM30G"
    build_link(forum,product, title, link)
    title = "OE2 audio headphones - white"
    link = "Bose-346018-0030-OE2-audio-headphones/product-reviews/B005KJMTXM"
    build_link(forum,product, title, link)
  end

  def am_links_9_29
    forum = Forum.find_by_name("Amazon")
    product = Product.where(:name => "QC 15").first
    title = "Bose QuietComfort 15 Acoustic Noise Cancelling Headphones - Limited Edition"
    link = "Bose-QuietComfort-Acoustic-Cancelling-Headphones/product-reviews/B00EWJHRMY"
    build_link(forum,product, title, link)

    product = Product.where(:name => "OE2").first
    title = "Bose OE2 audio headphones - Black"
    link = "Bose-OE2-audio-headphones-Black/product-reviews/B005KJM30G"
    build_link(forum,product, title, link)
    title = "Bose OE2 audio headphones - White"
    link = "Bose-OE2-audio-headphones-White/product-reviews/B005KJMTXM"
    build_link(forum,product, title, link)

    product = product = Product.find_by_name("SoundLink Mini Covers")
    title = "SoundLink Mobile Bi-fold Cover - Blue Nylon"
    link = "SoundLink%C2%AE-Mobile-Bi-fold-Cover-Nylon/product-reviews/B009NB99FO"
    build_link(forum,product, title, link)


  end

  def am_links_10_14
    forum = Forum.find_by_name("Amazon")
    product = Product.where(:name => "OE").first
    title = "Bose OE Audio Headphones"
    link = "Bose-BOSE-OE-OE-Audio-Headphones/product-reviews/B0081X1R8C"
  end

end
