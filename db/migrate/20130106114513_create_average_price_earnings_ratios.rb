class CreateAveragePriceEarningsRatios < ActiveRecord::Migration
  def change
    create_table :average_price_earnings_ratios do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :three_years_ago, :default => -1
      t.integer :two_years_ago, :default => -1
      t.integer :last_year, :default => -1
      t.integer :this_year, :default => -1
      t.integer :next_year, :default => -1
      t.float :average
      t.float :value_three_years_ago, :default => -1
      t.float :value_two_years_ago, :default => -1
      t.float :value_last_year, :default => -1
      t.float :value_this_year, :default => -1
      t.float :value_next_year, :default => -1
      t.belongs_to :score_card, index: true

      t.timestamps
    end
  end
end
