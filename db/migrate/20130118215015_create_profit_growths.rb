class CreateProfitGrowths < ActiveRecord::Migration
  def change
    create_table :profit_growths do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.date :this_year
      t.date :next_year
      t.float :value_this_year
      t.float :value_next_year
      t.float :perf

      t.timestamps
    end
  end
end
