class CreateDeniedCodes < ActiveRecord::Migration
  def change
    create_table :denied_codes do |t|
      t.string :code, null: false
      t.references :forum

      t.timestamps
    end
    add_index :denied_codes, :code, unique: true
  end
end

