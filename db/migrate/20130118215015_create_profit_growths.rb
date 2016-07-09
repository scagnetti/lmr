class CreateProfitGrowths < ActiveRecord::Migration
  def change
    create_table :profit_growths do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :this_year, :default => -1
      t.integer :next_year, :default => -1
      t.float :value_this_year, :default => -1
      t.float :value_next_year, :default => -1
      t.float :perf
      t.belongs_to :score_card, index: true

      t.timestamps
    end
  end
end
