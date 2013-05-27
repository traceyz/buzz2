class Review < ActiveRecord::Base

  belongs_to :link_url

  validates :author, presence: true
  validates :rating, numericality: { only_integer: true }
  validates :review_date, presence: true
  validates :unique_key, presence: true, uniqueness: true

  attr_accessible :author, :rating, :review_date, :unique_key, :headline, :body, :location, :link_url_id

end
