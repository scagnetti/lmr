class CreateInsiderDeals < ActiveRecord::Migration
  def change
    create_table :insider_deals do |t|
      t.references :share
      t.date :occurred
      t.string :person
      t.integer :quantity
      t.float :price
      t.integer :trade_type
      t.string :link

      t.timestamps
    end
  end
end
