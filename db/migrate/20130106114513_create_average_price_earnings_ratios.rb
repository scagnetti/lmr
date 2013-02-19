class CreateAveragePriceEarningsRatios < ActiveRecord::Migration
  def change
    create_table :average_price_earnings_ratios do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :three_years_ago
      t.integer :two_years_ago
      t.integer :last_year
      t.integer :this_year
      t.integer :next_year
      t.float :average
      t.float :value_three_years_ago
      t.float :value_two_years_ago
      t.float :value_last_year
      t.float :value_this_year
      t.float :value_next_year

      t.timestamps
    end
  end
end
