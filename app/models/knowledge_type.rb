#coding: utf-8

class KnowledgeType
  include Mongoid::Document
  include Mongoid::Timestamps

  validates_presence_of :name, :image
  validates_uniqueness_of :name
  validates_numericality_of :priority, :greater_than_or_equal_to => 0
  
  field :name, :type => String
  field :image, :type => String
  field :priority, :type => Integer, :default => 0
  
end