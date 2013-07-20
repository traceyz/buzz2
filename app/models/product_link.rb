class ProductLink < ActiveRecord::Base

  has_many :link_urls
  belongs_to :forum
  belongs_to :product

  validates :active, presence: true

  attr_accessor :active

  def report_count(report_date)
    link_urls.map{ |lu| lu.report_count(report_date) }.sum
  end

  def report_reviews(report_date)
    link_urls.map{ |lu| lu.report_reviews(report_date) }.flatten
  end

  def new_reviews(args)
    link_urls.map{ |lu| lu.new_reviews(args) }.flatten
  end

  # args is {report_date, :recent_date}
  def new_count(args)
    link_urls.map{|lu| lu.new_count(args) }.sum
  end

end
