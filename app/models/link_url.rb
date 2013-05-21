class LinkUrl < ActiveRecord::Base

  belongs_to :product_link

  validates :link, :current, presence: true

  attr_accessible :link, :current

end
