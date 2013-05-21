class Product < ActiveRecord::Base

  has_many :product_links
  belongs_to :category

  attr_accessible [ :name ]

  validates :name,  presence: true, uniqueness: true

end
