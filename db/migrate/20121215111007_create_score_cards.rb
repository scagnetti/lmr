class CreateScoreCards < ActiveRecord::Migration
  def change
    create_table :score_cards do |t|
      t.references :share
      t.float :price
      t.string :currency
      t.integer :total_score, :default => 0
      
      t.timestamps
    end
  end
end
