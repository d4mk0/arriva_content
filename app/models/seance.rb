class Seance < ActiveRecord::Base
  belongs_to :hall
  
  attr_accessible :hall_name, :date, :name, :time, :price
end
