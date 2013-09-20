class Hall < ActiveRecord::Base
  belongs_to :cinema
  has_many :seances
  
  attr_accessible :cinema_id, :name, :id_at_arriva
  
  validates_uniqueness_of :id_at_arriva
  validates_presence_of :name
end
