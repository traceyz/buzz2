module LoadData

# use this to load the links => products
# recognize that since we aren't using forum product names,
# within a  forum,  there may be multiple links for a product
# - as in different colors
  def read_file(file_name)
    path = "#{Rails.root}/lib/load_data/#{file_name}"
    IO.readlines(path)
  end

  def load_amazon
    forum = Forum.find_by_name("Amazon")
    data = read_file("am_links.txt")
    data.each do |datum|
      link, forum_name, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
    nil
  end

  def load_apple
    forum = Forum.find_by_name("Apple")
    data = read_file("ap_links.txt")
    data.each do |datum|
      link, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
    nil
  end

  def load_best_buy
    forum = Forum.find_by_name("BestBuy")
    data = read_file("bb_links.txt")
    data.each do |datum|
      next unless datum
      link, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
    nil
  end

  def load_bbuk
    forum = Forum.find_by_name("Revoo")
    data = read_file("bbuk_links.txt")
    data.each do |datum|
      next unless datum
      link, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
    nil
  end

  def load_cnet
    forum = Forum.find_by_name("Cnet")
    data = read_file("cnet_links.txt")
    data.each do |datum|
      next unless datum
      link, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
    nil
  end

  def load_fs
    forum = Forum.find_by_name("FutureShop")
    data = read_file("fs_links.txt")
    data.each do |datum|
      link, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
    nil
  end

  def load_ne
    forum = Forum.find_by_name("NewEgg")
    data = read_file("ne_links.txt")
    data.each do |datum|
      link, product_name = datum.chomp.split(",")
      next if product_name.eql?("UNCERTAIN")
      product = Product.find_by_name(product_name.strip)
      raise "NO PRODUCT FOR #{product_name}" unless product
      build_link(forum, product, link.strip)
    end
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
