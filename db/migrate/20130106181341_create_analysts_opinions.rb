class CreateAnalystsOpinions < ActiveRecord::Migration
  def change
    create_table :analysts_opinions do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :buy
      t.integer :hold
      t.integer :sell

      t.timestamps
    end
  end
end
