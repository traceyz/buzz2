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

  def update_links
    Forum.find_by_name("Amazon").product_links.where(:product_id => 66).first.link_urls.create!(
      link: "Bose-AE2w-Bluetooth-Headphones-Black/product-reviews/B00CD1FB26",
      title: "Bose AE2w Bluetooth Headphones - Black",
      current: true)
  end

end
