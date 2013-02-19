class CreateMomenta < ActiveRecord::Migration
  def change
    create_table :momenta do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.references :stock_price_dev_half_year
      t.references :stock_price_dev_one_year

      t.timestamps
    end
  end
end
