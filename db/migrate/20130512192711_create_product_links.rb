class CreateProductLinks < ActiveRecord::Migration
  def change
    create_table :product_links do |t|
      t.boolean :active, default: false
      t.references :forum, null: false
      t.references :product, null: false
      t.timestamps
    end
  end
end
