class Category < ActiveRecord::Base

  require 'path_name'
  include PathName

  has_many :products
  has_many :categories

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  attr_accessible :name, :position, :category_id

  def report_count(report_date)
    all_products.map{ |p| p.report_count(report_date) }.sum
  end

  # args = { :report_date, :recent_date }
  def new_count(args)
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

  def parent_name
    category_id.nil? ? name : Category.find(category_id).name
  end

  def page_name
    "#{clean_name(parent_name)}.html"
  end

end
