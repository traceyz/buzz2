class Category < ActiveRecord::Base

  require 'path_name'
  include PathName

  has_many :products

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  attr_accessible :name, :position

  def report_count(report_date)
    products.includes(:product_links).map{ |p| p.report_count(report_date) }.sum
  end

  # args = { :report_date, :recent_date }
  def new_count(args)
    products.includes(:product_links).map{ |p| p.new_count(args) }.sum
  end

end
