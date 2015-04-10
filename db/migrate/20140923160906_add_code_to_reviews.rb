class AddCodeToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :code, :string
  end
end
