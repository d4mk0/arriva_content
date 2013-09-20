class CreateHalls < ActiveRecord::Migration
  def change
    create_table :halls do |t|
      t.string :name
      t.integer :id_at_arriva
      t.integer :cinema_id
      t.timestamps
    end
  end
end
