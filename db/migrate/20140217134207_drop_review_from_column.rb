class DropReviewFromColumn < ActiveRecord::Migration
  def up
    remove_column :reviews, :review_from
  end

  def down
  end
end
