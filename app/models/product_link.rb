class ProductLink < ActiveRecord::Base

  has_many :link_urls
  belongs_to :forum
  belongs_to :product

  validates :active, presence: true

  attr_accessor :active

end
