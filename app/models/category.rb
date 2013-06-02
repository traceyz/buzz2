class Category < ActiveRecord::Base

  has_many :products

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  attr_accessible :name, :position

  def review_count
    products.includes(:product_links).map(&:review_count).sum
  end

  def new_review_count
    products.includes(:product_links).map(&:new_review_count).sum
  end

end
