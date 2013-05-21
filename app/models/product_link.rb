class ProductLink < ActiveRecord::Base

  has_many :link_urls
  has_many :reviews
  belongs_to :forum
  belongs_to :product

  validates :active, presence: true

  attr_accessor :active, :forum, :product

end
