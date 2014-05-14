class CreateRisingScores < ActiveRecord::Migration
  def change
    create_table :rising_scores do |t|
      t.references :share
      t.integer :days
      t.string :isin

      t.timestamps
    end
  end
end
