class ChangeLocationDefault < ActiveRecord::Migration
  def up
    change_column :reviews, :location, :string, :default => nil
  end

  def down
    change_column :reviews, :location, :string, :default => ""
  end
end
