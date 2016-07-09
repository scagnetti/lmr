class CreateInsiderDeals < ActiveRecord::Migration
  def change
    create_table :insider_deals do |t|
      t.date :occurred
      t.string :person
      t.integer :quantity
      t.float :price
      t.integer :transaction_type, default: 0
      t.string :link
      t.belongs_to :insider_info, index: true

      t.timestamps
    end
  end
end
