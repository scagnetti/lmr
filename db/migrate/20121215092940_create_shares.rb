class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.boolean :active, :default => true
      t.string :name, :null => false
      t.string :isin, :null => false, :uniqueness => true
      t.boolean :financial
      t.integer :size
      t.string :stock_exchange # Which stock exchange should be used?
      t.string :currency # In which currency should the rating be conducted
      t.references :stock_index

      t.timestamps
    end
  end
end
