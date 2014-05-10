class Product < ActiveRecord::Base

  has_many :product_links
  has_many :review_froms
  belongs_to :category

  attr_accessible :name, :category_id

  require 'path_name'
  include PathName

  validates :name,  presence: true, uniqueness: true

  def report_reviews(report_date)
    product_links.includes(:link_urls).map{ |pl| pl.report_reviews(report_date) }.flatten.sort_by(&:review_date).reverse[0..Review::MAX_REVIEWS]
  end

  # args = {:recent_date .. , :report_date  }
  def new_reviews(args)
    product_links.includes(:link_urls).map{ |pl| pl.new_reviews(args) }.flatten.sort_by(&:review_date).reverse
  end

  def report_count(report_date)
    [product_links.includes(:link_urls).map{ |pl| pl.report_count(report_date) }.sum, Review::MAX_REVIEWS].min
  end

# args = {:recent_date .. , :report_date  }
  def new_count(args)
    product_links.includes(:link_urls).map{|pl| pl.new_count(args)}.sum
  end

end
