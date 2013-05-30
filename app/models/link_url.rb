class LinkUrl < ActiveRecord::Base

  belongs_to :product_link
  has_many :reviews

  validates :link, presence: true, uniqueness: true
  validates :current, :title, presence: true

  attr_accessible :link, :current, :title

  delegate :forum, :to => :product_link

end
