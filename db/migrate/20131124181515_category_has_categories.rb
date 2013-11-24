class CategoryHasCategories < ActiveRecord::Migration
  def up
    add_column :categories, :category_id, :integer
  end

  def down
    remove_column :categories, :category_id
  end
end
