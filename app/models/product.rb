class Product < ActiveRecord::Base

  has_many :product_links
  belongs_to :category

  attr_accessible :name

  require 'path_name'
  include PathName

  validates :name,  presence: true, uniqueness: true

  def report_reviews(report_date)
    #product_links.includes(:link_urls).map(&:reviews).select{ |r| r.review_date <= report_date }.flatten.sort_by(&:review_date).reverse[0..Review::MAX_REVIEWS]
    product_links.includes(:link_urls).map{ |pl| pl.report_reviews(report_date) }.flatten.sort_by(&:review_date).reverse[0..Review::MAX_REVIEWS]
  end

  # args = {:recent_date .. , :report_date  }
  def new_reviews(args)
    #reviews.where(:review_date <= args[:report_date], :review_date >= args[:recent_date]).order('review_date DESC')
    #reviews.select{ |review| review.review_date >= recent && review.review_date <= report_date }
    product_links.includes(:link_urls).map{ |pl| pl.new_reviews(args) }.flatten.sort_by(&:review_date).reverse
  end

  def report_count(report_date)
    [product_links.includes(:link_urls).map{ |pl| pl.report_count(report_date) }.sum, Review::MAX_REVIEWS].min
    #[product_links.includes(:link_urls).map(&:review_count).sum, Review::MAX_REVIEWS].min
  end

# args = {:recent_date .. , :report_date  }
  def new_count(args)
    product_links.includes(:link_urls).map{|pl| pl.new_count(args)}.sum
  end

end
