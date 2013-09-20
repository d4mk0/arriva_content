class CreateCinemas < ActiveRecord::Migration
  def change
    create_table :cinemas do |t|
      t.string :name
      t.string :schedule_address
      t.timestamps
    end
  end
end
