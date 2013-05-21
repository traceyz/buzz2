# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

[
  %w(Amazon http://www.amazon.com/ am_logo.png),
  %w(Apple http://store.apple.com/us/reviews/ ap_logo.png),
  %w(BestBuy http://www.bestbuy.com/site/ bb_logo.png),
  %w(Cnet tbd tbd),
  %w(FutureShop tbd tbd),
  %w(NewEgg tbd tbd),
  %w(Revoo tbd tbd),
  %w(Target tbd tbd)
].each do |data|
  name, root, image = data
  Forum.create!(:name => name, :root => root, :image => image)
end

[
  "Lifestyle DVD-based Systems",
  "Lifestyle Component-based Systems",
  "321 Systems",
  "Home Theater Speakers",
  "TV Speakers",
  "Multimedia Speakers",
  "Stereo Speakers",
  "Outdoor Speakers",
  "Wave Products",
  "Headphones",
  "Video Systems",
  "Lifestyle Accessories"
].each_with_index do |name, position|
  Category.create!(:name => name, :position => position)
end


