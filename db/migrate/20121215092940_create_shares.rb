class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.boolean :active, :default => true
      t.string :name, :null => false
      t.string :isin, :null => false, :uniqueness => true
      t.boolean :financial
      t.integer :size
      t.date :asm #annual stockholders meeting (Hauptversammlung)
      t.references :stock_index

      t.timestamps
    end
  end
end
