ReviewFrom.create!(:phrase => "SoundLink Bluetooth Mobile Speaker II", :product_id => 40)

ReviewFrom.create!(:phrase => "SoundLink Mini Bluetooth Wireless Speaker and Gray Soft Silicon Cover",
  :product_id => 88)

ReviewFrom.create!(:phrase => "SoundLink Mini Bluetooth Wireless Speaker and Red Soft Silicon Cover",
  :product_id => 88)

[
  ["LIFESTYLE 48 Home Entertainment System - Series IV", 7],
  ["SoundLink Mini Bluetooth Wireless Speaker and Pink Soft Silicon Cover", 88],
  ["SoundLink Mini Bluetooth Wireless Speaker and Mint Green Soft Silicon Cover", 88],
  ["SoundLink Bluetooth Mobile Speaker III  Blue Cover", 134],
  ["SoundTouch SA-4 Amplifier", 112]
].each do |phrase, id|
  ReviewFrom.create!(:phrase => phrase, :product_id => id)
end


# Load new review froms -- in the printed file, each has a link_url_id
# put that into the lower array to retrieve the missing reviews
# maybe later, have the review from load push those ids into the array

[
  ["Acoustimass 10 Series III -Silver", 18],
  ["Acoustimass 7 - Speaker System, Ideal for Stereo or Home Theater Use", 22],
  ["901 Series VI Ver.2 Special Edition Speaker System", 54],
  ["SoundDock Series II Digital Music System", 35]
].each do |phrase, id|
    ReviewFrom.create!(:phrase => phrase, :product_id => id)
end;1

product_links = [751, 1023, 11, 1042, 1046, 1045].map{ |id| LinkUrl.find(id).product_link };1
AmazonScraper.get_reviews(true, product_links)
  

# 2014-09-01  
[
  ["OE2i audio headphones", 76],
  ["Acoustimass 5 - Speaker System, ideal for stereo or home theater use", 56],
  ["161 Speaker System", 45],
  ["151 SE Elegant Outdoor Speakers", 44],
  ["329198-1100 CineMate 1 SR Home Theater Speaker System", 25],
  ["SoundTouch Controller, Black", 110]
].each do |phrase, id|
      ReviewFrom.create!(:phrase => phrase, :product_id => id)
end;1