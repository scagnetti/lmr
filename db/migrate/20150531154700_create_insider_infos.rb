class CreateInsiderInfos < ActiveRecord::Migration
  def change
    create_table :insider_infos do |t|
      t.boolean :succeeded, :default => true
      t.integer :score, :default => -1
      t.text :error_msg
      t.belongs_to :score_card, index: true

      t.timestamps null: false
    end
  end
end
