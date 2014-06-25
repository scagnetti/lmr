class CreateEquityRatios < ActiveRecord::Migration
  def change
    create_table :equity_ratios do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :last_year, :default => -1
      t.float :value, :default => -1

      t.timestamps
    end
  end
end
