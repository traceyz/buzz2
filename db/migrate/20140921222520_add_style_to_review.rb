class AddStyleToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :style, :string
  end
end
