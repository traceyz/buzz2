class Forum < ActiveRecord::Base

  has_many :product_links

  validates :name, :image, :root, presence: true

  attr_accessible :name, :image, :root, :tail, :id

  def new_count(args)
    product_links.map{|pl| pl.new_count(args) }.sum
  end

end
