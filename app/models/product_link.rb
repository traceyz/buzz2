class ProductLink < ActiveRecord::Base

  has_many :link_urls
  belongs_to :forum
  belongs_to :product

  validates :active, presence: true

  attr_accessor :active

  def review_count
    link_urls.map{|u| u.reviews.count}.sum
  end

  def reviews
    link_urls.map(&:reviews)
  end

  def new_review_count(recent_date)
    link_urls.map{|u| u.reviews.where(['review_date >= ?', recent_date]).count}.sum
  end

end
