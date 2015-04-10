class Forum < ActiveRecord::Base

  has_many :product_links
  has_many :denied_codes

  validates :name, :image, :root, presence: true

  attr_accessible :name, :image, :root, :tail, :id

  def new_count(args)
    product_links.map{|pl| pl.new_count(args) }.sum
  end

  def list_links
    product_links.sort_by{|pl| pl.product.name}.each do |pl|
      puts
      puts pl.product.name
      pl.link_urls.each do |lu|
        puts "#{lu.title} #{lu.link}"
      end
    end
    nil
  end

  # when adding new links, we take put the root and possibly the tail
  # http://www.amazon.com/Bose-Model-Single-Portable-System/product-reviews/B009HUM2IW
  # becomes Bose-Model-Single-Portable-System/product-reviews/B009HUM2IW
  def link_from_url(url)
    url =~ /amazon.com\/(.+)\z/
    $1
  end

  # over-ridden by a forum that actually has and uses product codes
  # the specific id in the link
  # for eaxmple - in Amazon, a link is Bose-727012-1300-Bluetooth-Audio-Adapter/dp/B00NTUEDMY
  # the product code is B00NTUEDMY - what follows the last forward slash
  def product_codes
    []
  end

end
