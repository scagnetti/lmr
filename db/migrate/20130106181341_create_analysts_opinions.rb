class CreateAnalystsOpinions < ActiveRecord::Migration
  def change
    create_table :analysts_opinions do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :buy, :default => -1
      t.integer :hold, :default => -1
      t.integer :sell, :default => -1

      t.timestamps
    end
  end
end
