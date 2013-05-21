module LoadData

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
      %w(Revoo bbuk_links.txt),
      %w(Cnet cnet_links.txt),
      %w(FutureShop fs_links.txt),
      %w(NewEgg ne_links.txt)
    ]
    data.each do |forum_name, file_name|
      load_forum(forum_name, file_name)
    end
    nil
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
    forum = Forum.find_by_name(forum_name)
    data = read_file(file_name)
    data.each do |datum|
      link, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      puts "PRODUCT NAME #{product_name}"
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
    puts "complete links load for #{forum_name}"
    nil
  end

  def build_link(forum, product, link)
    p_l = forum.product_links.where(:product_id => product.id).first ||
             forum.product_links.new(:product_id => product.id)
    p_l.update_attributes!(:active => true)
    link_url = p_l.link_urls.where(:link => link).first ||
                    p_l.link_urls.new(:link => link)
    link_url.update_attributes!(:current => true)
    nil
  end

end
