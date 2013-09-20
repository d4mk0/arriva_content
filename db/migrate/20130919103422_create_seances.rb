class CreateSeances < ActiveRecord::Migration
  def change
    create_table :seances do |t|
      t.string :film_name
      t.integer :hall_id
      t.integer :price
      t.datetime :datetime
      t.timestamps
    end
  end
end
