class AddExcludeToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :exclude, :boolean, :default => false
  end
end
