class CreateScoreCards < ActiveRecord::Migration
  def change
    create_table :score_cards do |t|
      t.references :share
      t.float :price
      t.string :currency
      t.integer :total_score, :default => 0
      t.references :return_on_equity
      t.references :ebit_margin
      t.references :equity_ratio
      t.references :current_price_earnings_ratio
      t.references :average_price_earnings_ratio
      t.references :analysts_opinion
      t.references :reaction
      t.references :profit_revision
      t.references :stock_price_dev_half_year
      t.references :stock_price_dev_one_year
      t.references :momentum
      t.references :reversal
      t.references :profit_growth
      
      t.timestamps
    end
  end
end
