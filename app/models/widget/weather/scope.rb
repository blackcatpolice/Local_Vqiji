class Widget::Weather::Scope
  include Mongoid::Document

  has_many :cities, class_name: 'City'
  
  field :name
  field :code

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  
  index :name => 1
end
