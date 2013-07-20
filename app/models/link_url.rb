class LinkUrl < ActiveRecord::Base

  require 'open-uri'

  belongs_to :product_link
  has_many :reviews

  validates :link, presence: true, uniqueness: true
  validates :current, :title, presence: true

  attr_accessible :link, :current, :title

  delegate :forum, :to => :product_link
  delegate :product, :to => :product_link

  def report_reviews(report_date)
    reviews.where(['review_date <= ?', report_date])
  end

  def report_count(report_date)
    reviews.where(['review_date <= ?', report_date]).count
  end

  # args is {:report_date , :recent_date}
  def new_reviews(args)
    args[:recent_date] ||= args[:report_date]-14
    reviews.where(['review_date >= ? AND review_date <= ?', args[:recent_date], args[:report_date]])
  end

# args is {:report_date , :recent_date}
  def new_count(args)
    args[:recent_date] ||= args[:report_date]-14
    reviews.where(['review_date >= ? AND review_date <= ?', args[:recent_date], args[:report_date]]).count
  end

end
