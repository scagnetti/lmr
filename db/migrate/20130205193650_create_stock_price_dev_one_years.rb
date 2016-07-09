class CreateStockPriceDevOneYears < ActiveRecord::Migration
  def change
    create_table :stock_price_dev_one_years do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.float :compare, :default => -1
      t.float :value, :default => -1
      t.date :historical_date
      t.float :perf
      t.belongs_to :score_card, index: true

      t.timestamps
    end
  end
end
