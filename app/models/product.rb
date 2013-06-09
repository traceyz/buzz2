class Product < ActiveRecord::Base

  has_many :product_links
  belongs_to :category

  attr_accessible :name

  require 'path_name'
  include PathName

  validates :name,  presence: true, uniqueness: true

  def reviews
    product_links.includes(:link_urls).map(&:reviews).flatten.sort_by(&:review_date).reverse[0..Review::MAX_REVIEWS]
  end

  def recent_reviews(recent)
    reviews.select{ |review| review.review_date >= recent }
  end

  def review_count
    [product_links.includes(:link_urls).map(&:review_count).sum, Review::MAX_REVIEWS].min
  end

  def new_review_count(recent_date)
    [product_links.includes(:link_urls).map{|pl| pl.new_review_count(recent_date)}.sum, Review::MAX_REVIEWS].min
  end

end
