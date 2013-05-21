# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

DATA = [
  %w(Amazon http://www.amazon.com/ am_logo.png),
  %w(Apple http://store.apple.com/us/reviews/ ap_logo.png),
  %w(BestBuy tbd tbd),
  %w(Cnet tbd tbd),
  %w(FutureShop tbd tbd),
  %w(NewEgg tbd tbd),
  %w(Revoo tbd tbd),
  %w(Target tbd tbd)
]

DATA.each do |data|
  name, root, image = data
  forum = Forum.find_by_name(name) || Forum.new(:name => name)
  forum.update_attributes!(:root => root, :image => image)
end

cat = Category.find_or_create_by_name("Lifestyle DVD-based Systems")
cat.update_attributes!(:position => 1)
names = ["LS 12", "LS 18", "LS 28", "LS 30", "LS 35", "LS 38", "LS 48"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.size

cat = Category.find_or_create_by_name("Lifestyle Component-based Systems")
cat.update_attributes!(:position => 2)
names = ["LS 135", "LS 235", "LS T20", "LS V10", "LS V20", "LS V25", "LS V30", "LS V35"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.size

cat = Category.find_or_create_by_name("321 Systems")
cat.update_attributes!(:position => 3)
names = ["321", "321 GS"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.size

cat = Category.find_or_create_by_name("Home Theater Speakers")
cat.update_attributes!(:position => 4)
names = ["AM 10", "AM 15", "AM 16", "AM 6", "AM 7", "Acoustimass DirectReflecting Speaker" ] <<
["CineMate", "Cinemate 1 SR", "Jewel Cube Speakers", "VCS 10"]
names.flatten.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("TV Speakers")
cat.update_attributes!(:position => 5)
names = ["Bose Solo"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Multimedia Speakers")
cat.update_attributes!(:position => 6)
names = ["Companion 2", "Companion 20", "Companion 3", "Companion 5", "Computer Music Monitor" ] <<
["MediaMate", "SoundDock", "SoundDock 10", "SoundDock III", "SoundDock Portable"] <<
["SoundLink Air", "SoundLink Bluetooth", "Wireless Computer Speaker"]
names.flatten.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Apps")
cat.update_attributes!(:position => 7)
names = ["AM FM App"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Stereo Speakers")
cat.update_attributes!(:position => 8)
names = ["101", "141", "151", "161", "191", "201", "301", "501", "601", "6.2", "791", "802", "901", "AM 3", "AM 5"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Outdoor Speakers")
cat.update_attributes!(:position => 9)
names = ["131", "251", "FS 51"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Wave Products")
cat.update_attributes!(:position => 10)
names = ["AWMS", "Wave Control Pod", "Wave Radio", "Wave Radio CD", "Wave music system"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Headphones")
cat.update_attributes!(:position => 11)
names = ["AE2", "AE2w", "Bluetooth Headset", "Bluetooth Headset Series 2"] <<
["Bose Around-ear", "Bose In-ear", "Bose On-ear", "IE2", "MIE2"] <<
["Mobile In-Ear Headset", "Mobile On-Ear Headset"] <<
["OE2", "QC 15", "QC 2", "QC 3", "SIE2"]
names.flatten.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Video Systems")
cat.update_attributes!(:position => 12)
names = ["VideoWave", "VideoWave II-46", "VideoWave II-55"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size

cat = Category.find_or_create_by_name("Lifestyle Accessories")
cat.update_attributes!(:position => 13)
names = ["SL2"]
names.each do |name|
  cat.products.find_or_create_by_name(name)
end
raise "PRODUCT CREATION FAILED" unless cat.products.count == names.flatten.size
