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

  def self.list_products
    Category.order('position ASC, name ASC').each do |cat|
      puts "#{cat.position} #{cat.name}"
      cat.products.each{|p| puts p.name}
      puts
    end
    nil
  end

end
