class CreateReviewFrom < ActiveRecord::Migration
  def up

    create_table :review_froms do |t|
      t.string :phrase, null: false
      t.references :product
      t.timestamps
    end

    add_column :reviews, :review_from_id, :integer

    add_index :review_froms, :phrase, unique: true
  end

  def down
    drop_table :review_froms
    drop_column :reviews, :review_from_id
  end
end
