class CreateReactions < ActiveRecord::Migration
  def change
    create_table :reactions do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.date :release_date
      t.date :before
      t.date :after
      t.float :price_before
      t.float :price_after
      t.float :index_before
      t.float :index_after
      t.float :share_perf
      t.float :index_perf

      t.timestamps
    end
  end
end
