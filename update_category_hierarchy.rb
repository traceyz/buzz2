def update_categories
  new_parent = Category.where(:name => "Lifestyle Component-based Systems").first
  old_parent = Category.where(:name => "Home Theater Console Systems").first
  old_parent.products.each{|p| p.update_attributes!(:category_id => new_parent.id)}
  blue = Category.where(:name => "Bluetooth Speakers").first
  ["SoundLink Bluetooth", "SoundLink Mini", "SoundLink Mini Covers"].each do |name|
    Product.where(:name => name).first.update_attributes!(:category_id => blue.id)
  end
  ipod = Category.where(:name => "iPod Speakers").first
  ["SoundDock", "SoundDock 10", "SoundDock III", "SoundDock Portable", "SoundLink Air"].each do |name|
    Product.where(:name => name).first.update_attributes!(:category_id => ipod.id)
  end
  cs = Category.where(:name => "Computer Speakers").first
  ["Companion 2 Series III", "Companion 2", "Companion 20", "Companion 3", "Companion 5",
    "Computer Music Monitor", "MediaMate", "Wireless Computer Speaker"].each do |name|
      Product.where(:name => name).first.update_attributes!(:category_id => cs.id)
  end
  nil
end

def update_headphone_categories
  parent = Category.where(:name => "Headphones").first
  ["Audio Headphones", "Noise Cancelling Headphones", "Bluetooth Headsets"].each do |name|
    parent.categories.create!(:name => name, :position => 100)
  end
  audio = Category.where(:name => "Audio Headphones").first
  ["AE2", "AE2w", "OE2", "IE2", "MIE2", "SIE2", "Bose Around-ear", "Bose In-ear",
    "Bose On-ear", "OE", "Mobile In-Ear Headset", "Mobile On-Ear Headset"].each do |name|
    Product.where(:name => name).first.update_attributes!(:category_id => audio.id)
  end
  nc = Category.where(:name => "Noise Cancelling Headphones").first
  ["QC 15", "QC 20", "QC 3", "QC 2"].each do |name|
    Product.where(:name => name).first.update_attributes!(:category_id => nc.id)
  end
  bt = Category.where(:name => "Bluetooth Headsets").first
  ["Bluetooth Headset Series 2", "Bluetooth Headset"].each do |name|
    Product.where(:name => name).first.update_attributes!(:category_id => bt.id)
  end
  nil
end

def update_category_hierarchy
  Category.where(:name => "Lifestyle Component-based Systems") \
    .first.update_attributes!(:name => "Lifestyle Component Systems")
  ht = Category.where(:name => "Home Theater Console Systems").first
  ["Lifestyle Component Systems", "Lifestyle DVD-based Systems",
    "Lifestyle Accessories", "321 Systems"].each do |name|
    Category.where(:name => name).first.update_attributes!(:category_id => ht.id)
  end
  ls = Category.where(:name => "Loudspeakers").first
  ["Stereo Speakers", "Outdoor Speakers"].each do |name|
    Category.where(:name => name).first.update_attributes!(:category_id => ls.id)
  end
  nil
end


def list_categories
  Category.all.each do |cat|
    puts "#{cat.id} #{cat.name}"
    cat.products.sort_by(&:name).reverse.each{|p| puts "  #{p.name}"}
    puts
  end
  nil
end

def list_hierarchy
  Category.order(:position).where("category_id IS NULL").reject{|c| c.name == "Multimedia Speakers"}.each do |cat|
    puts "#{cat.name} #{cat.position}"
    cat.products.each{|p| puts p.name}
    cat.categories.each do |sub_cat|
      puts "  #{sub_cat.name} #{sub_cat.products.count}"
      sub_cat.products.each{|p| puts "    #{p.name}"}
    end
  end
  nil
end


