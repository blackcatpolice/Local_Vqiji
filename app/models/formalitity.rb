class Formalitity
	include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable

  field :title
  field :content
  belongs_to :creater, class_name: 'User'
  field :read, type: Boolean, default: false
  field :visible, type: Boolean, default: false
  mount_uploader :picture, PictureUploader

	validates_presence_of :creater, :title, :content
end
