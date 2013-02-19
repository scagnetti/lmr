class CreateProfitRevisions < ActiveRecord::Migration
  def change
    create_table :profit_revisions do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :up
      t.integer :equal
      t.integer :down

      t.timestamps
    end
  end
end
