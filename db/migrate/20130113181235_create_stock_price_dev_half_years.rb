class CreateStockPriceDevHalfYears < ActiveRecord::Migration
  def change
    create_table :stock_price_dev_half_years do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.float :compare
      t.float :value
      t.float :perf

      t.timestamps
    end
  end
end
