class CreateStockIndices < ActiveRecord::Migration
  def change
    create_table :stock_indices do |t|
      t.string :isin, :null => false, :uniqueness => true
      t.string :name, :null => false

      t.timestamps
    end
  end
end
