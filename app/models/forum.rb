class Forum < ActiveRecord::Base

  has_many :product_links

  validates :name, :image, :root, presence: true

  attr_accessible :name, :image, :root, :tail, :id

end
