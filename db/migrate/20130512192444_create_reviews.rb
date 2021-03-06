class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :type
      t.date :review_date, null: false
      t.string :author, null: false
      t.string :location, default: ""
      t.integer :rating, null: false
      t.string :headline, default: ""
      t.text :body, default: ""
      t.string :unique_key, null: false
      t.references :link_url, null: false

      t.timestamps
    end

    add_index :reviews, :unique_key, unique: true
  end
end
