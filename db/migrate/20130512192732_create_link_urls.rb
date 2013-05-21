class CreateLinkUrls < ActiveRecord::Migration
  def change
    create_table :link_urls do |t|
      t.string :link, null: false
      t.boolean :current, default: false
      t.references :product_link
      t.timestamps
    end

    add_index :link_urls, :link, unique: true
  end
end
