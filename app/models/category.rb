class Category < ActiveRecord::Base

  has_many :products

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  attr_accessible :name, :position

end
