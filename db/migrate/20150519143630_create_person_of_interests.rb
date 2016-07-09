class CreatePersonOfInterests < ActiveRecord::Migration
  def change
    create_table :person_of_interests do |t|
      t.string :first_name
      t.string :last_name
      t.string :desc

      t.timestamps
    end
  end
end
