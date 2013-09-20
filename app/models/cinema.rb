class Cinema < ActiveRecord::Base
  has_many :halls
  
  attr_accessible :name, :schedule_address
  
  validates_presence_of :name, :schedule_address
end
