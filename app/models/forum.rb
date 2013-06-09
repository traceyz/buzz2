class Forum < ActiveRecord::Base

  has_many :product_links

  validates :name, :image, :root, presence: true

  attr_accessible :name, :image, :root, :tail, :id

  def new_review_count(recent)
    product_links.map{|pl| pl.new_review_count(recent) }.sum
  end

end
