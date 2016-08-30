class CreateBuyTransactions < ActiveRecord::Migration
  def change
    create_table :buy_transactions do |t|
      t.date :occurred
      t.float :price
      t.string :currency
      t.integer :amount
      t.float :fees
      t.belongs_to :deposit_entry, index: true

      t.timestamps null: false
    end
  end
end
