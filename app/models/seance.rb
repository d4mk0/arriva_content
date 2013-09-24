class Seance < ActiveRecord::Base
  belongs_to :hall
  
  attr_accessible :film_name, :datetime, :price, :hall
  
  before_create :check_double
  
  def check_double
    Seance.where(:film_name => film_name, :datetime => datetime, :hall_id => hall).blank?
  end
  
  def self.seances_for_day(hall, date)
    if hall.present? and date.present?
      date = Time.parse(date)
      Seance.order(:datetime ).
          where("hall_id = ? AND datetime > ? AND datetime < ?", hall, date, date.end_of_day)
    end
  end
  
  def self.change_film_name(old_name, new_name)
    Seance.where(:film_name => old_name).each do |s|
      s.update_attribute(:film_name, new_name)
    end
  end
end
