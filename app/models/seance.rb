class Seance < ActiveRecord::Base
  belongs_to :hall
  
  attr_accessible :film_name, :datetime, :price, :hall
end
