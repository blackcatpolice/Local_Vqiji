class Type
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  
  field :summary

end
