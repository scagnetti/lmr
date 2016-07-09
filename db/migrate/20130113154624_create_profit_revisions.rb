class CreateProfitRevisions < ActiveRecord::Migration
  def change
    create_table :profit_revisions do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.integer :up, :default => -1
      t.integer :equal, :default => -1
      t.integer :down, :default => -1
      t.belongs_to :score_card, index: true

      t.timestamps
    end
  end
end
