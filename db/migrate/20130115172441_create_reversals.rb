class CreateReversals < ActiveRecord::Migration
  def change
    create_table :reversals do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.date :four_months_ago
      t.date :three_months_ago
      t.date :two_months_ago
      t.date :one_month_ago
      
      t.float :value_four_months_ago
      t.float :value_three_months_ago
      t.float :value_two_months_ago
      t.float :value_one_month_ago
      
      t.float :value_perf_three_months_ago
      t.float :value_perf_two_months_ago
      t.float :value_perf_one_month_ago
      
      t.float :index_four_months_ago
      t.float :index_three_months_ago
      t.float :index_two_months_ago
      t.float :index_one_month_ago
      
      t.float :index_perf_three_months_ago
      t.float :index_perf_two_months_ago
      t.float :index_perf_one_month_ago

      t.timestamps
    end
  end
end
