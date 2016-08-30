class CreateDepositEntries < ActiveRecord::Migration
  def change
    create_table :deposit_entries do |t|
      t.float :balance, :default => 0.0
      t.boolean :archived, :default => false
      t.references :share

      t.timestamps null: false
    end
  end
end
