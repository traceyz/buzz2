class Review < ActiveRecord::Base

  belongs_to :product

  validates :author, presence: true
  validates :rating, numericality: { only_integer: true }
  validates :review_date, presence: true
  validates :unique_key, presence: true, uniqueness: true

  attr_accessible :author, :rating, :review_date, :unique_key, :headline, :body, :location, :product_link_id

end
