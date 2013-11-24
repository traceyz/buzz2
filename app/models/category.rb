class Category < ActiveRecord::Base

  require 'path_name'
  include PathName

  has_many :products
  has_many :categories

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  attr_accessible :name, :position, :category_id

  def report_count(report_date)
    # if categories.first
    #   categories.map{|c| report_count(report_date)}.sum
    # else
    #   products.includes(:product_links).map{ |p| p.report_count(report_date) }.sum
    # end
    # categories.map{|c| report_count(report_date)}.sum +
    # products.includes(:product_links).map{ |p| p.report_count(report_date) }.sum
    all_products.map{ |p| p.report_count(report_date) }.sum
  end

  # args = { :report_date, :recent_date }
  def new_count(args)
    1
    # categories.map{|c| c.new_count(args)}.sum +
    # products.includes(:product_links).map{ |p| p.new_count(args) }.sum
    all_products.map{ |p| p.new_count(args) }.sum
  end

  def all_products
    result = []
    if categories.first
      categories.each{|c| result << c.products}
    else
      result = products
    end
    result.flatten
  end

  def self.audio_for_video

  end

end
