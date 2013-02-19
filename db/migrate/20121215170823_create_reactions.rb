class CreateReactions < ActiveRecord::Migration
  def change
    create_table :reactions do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.date :release_date
      t.float :price_opening
      t.float :price_closing
      t.float :index_opening
      t.float :index_closing

      t.timestamps
    end
  end
end
