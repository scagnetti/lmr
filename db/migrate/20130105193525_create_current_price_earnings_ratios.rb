class CreateCurrentPriceEarningsRatios < ActiveRecord::Migration
  def change
    create_table :current_price_earnings_ratios do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :this_year
      t.float :value

      t.timestamps
    end
  end
end
