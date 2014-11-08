class Forum < ActiveRecord::Base

  has_many :product_links

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

end
