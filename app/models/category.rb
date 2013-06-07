class Category < ActiveRecord::Base

  require 'path_name'
  include PathName

  has_many :products

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  attr_accessible :name, :position

  def review_count
    [products.includes(:product_links).map(&:review_count).sum, 200].min
  end

  def new_review_count(recent_date)
    products.includes(:product_links).map{|p| p.new_review_count(recent_date)}.sum
  end

end
