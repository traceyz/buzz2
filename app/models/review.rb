class Review < ActiveRecord::Base

  belongs_to :link_url

  validates :author, presence: true
  validates :rating, numericality: { only_integer: true }
  validates :review_date, presence: true
  validates :unique_key, presence: true, uniqueness: true

  attr_accessible :author, :rating, :review_date, :unique_key, :headline, :body, :location, :link_url_id

  delegate :forum, :to => :link_url
  delegate :product, :to => :link_url
  delegate :title, :to => :link_url


  def self.display(idx)
    order('review_date DESC').page(idx)
  end

  def display_title
    title
  end

end
