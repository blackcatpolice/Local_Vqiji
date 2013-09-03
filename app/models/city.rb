# encoding: utf-8

# 城市
class City
  include Mongoid::Document
  
  attr_accessible :country, :province, :name, as: :admin

  field :country, type: String  # 国家
  field :province, type: String # 省/州
  field :name, type: String     # 城市

  validates :name, presence: true, uniqueness: { scope: [:province, :country] }
  
  def to_builder
    Jbuilder.new do |city|
      city.(self, :id, :name, :province, :country)
    end
  end
end
