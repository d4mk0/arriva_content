class Seance < ActiveRecord::Base
  belongs_to :hall
  
  attr_accessible :film_name, :datetime, :price, :hall
  
  before_create :check_double
  
  def check_double
    Seance.where(:film_name => film_name, :datetime => datetime, :hall_id => hall).blank?
  end
end
