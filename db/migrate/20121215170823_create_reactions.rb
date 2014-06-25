class CreateReactions < ActiveRecord::Migration
  def change
    create_table :reactions do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.date :release_date
      t.date :before
      t.date :after
      t.float :price_before, :default => -1
      t.float :price_after, :default => -1
      t.float :index_before, :default => -1
      t.float :index_after, :default => -1
      t.float :share_perf, :default => -1
      t.float :index_perf, :default => -1

      t.timestamps
    end
  end
end
