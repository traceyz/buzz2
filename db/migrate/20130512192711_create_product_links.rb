class CreateProductLinks < ActiveRecord::Migration
  def change
    create_table :product_links do |t|
      t.boolean :active, default: false
      t.references :forum
      t.references :product
      t.timestamps
    end
  end
end
