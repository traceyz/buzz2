class Product < ActiveRecord::Base

  has_many :product_links
  belongs_to :category

  attr_accessible :name

  validates :name,  presence: true, uniqueness: true

  def reviews
    product_links.includes(:link_urls).map(&:reviews).flatten.sort_by(&:review_date).reverse
  end

  def review_count
    product_links.includes(:link_urls).map(&:review_count).sum
  end

  def new_review_count(recent_date)
    product_links.includes(:link_urls).map{|pl| pl.new_review_count(recent_date)}.sum
  end

end
