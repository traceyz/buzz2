module LoadData

  def load_products
    data = [
        ["Lifestyle DVD-based Systems",
        ["LS 12", "LS 18", "LS 28", "LS 30", "LS 35", "LS 38", "LS 48"]
      ]
    ]
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
