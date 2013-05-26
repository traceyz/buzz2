class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.string :name, null: false
      t.string :image, null: false
      t.string :root, null: false
      t.string :tail
      t.timestamps
    end

    add_index :forums, :name, unique: true
  end
end
