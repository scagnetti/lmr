class CreateStockIndices < ActiveRecord::Migration
  def change
    create_table :stock_indices do |t|
      t.string :isin
      t.string :name

      t.timestamps
    end
  end
end
