#coding: utf-8
class Proposal::Suggest
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title
  
  field :content
  
  #不显示真名
  field :realname, type: Boolean, default: false

	#提议者
	field :sender_id, type: Integer
	
	#审核情况，同意1或者不同意0，默认未审核2
	field :check, type: Integer, default: 2
	
	#审核人
	field :finisher_id
	
	#是否完成审核
	#field :done, type: Boolean, default: false
	
	#审核意见
	field :mycomment
	
	field :comment_counts, type: Integer, default: 0
	
	# 附件
  embeds_one :file,class_name: 'Attachment::File'
  embeds_one :picture,  class_name: 'Attachment::Picture'
  embeds_one :audio,  class_name: 'Attachment::Audio' 
  
  has_many :comments, class_name: "Proposal::Comment", dependent: :destroy  
  
  #sender
  def sender
  	User.find(sender_id.to_s)
  end
  
  def finisher
  	User.find(finisher_id.to_s)
  end
  
  public
  def self._creates opts = {}
    _suggest = self.new
    _suggest.title = opts[:title]
    _suggest.content = opts[:content]
    _suggest.sender_id = opts[:sender_id]
    unless opts[:audioId].blank?
      _audio = Tmp::Audio.find(opts[:audioId])
      _suggest.audio = _audio.to_attachment _suggest unless _audio.blank?
    end
    
    unless opts[:pictureId].blank?
      _picture = Tmp::Picture.find(opts[:pictureId])
      _suggest.picture = _picture.to_attachment _suggest unless _picture.blank?
    end
    
    unless opts[:attachmentId].blank?
      _file = Tmp::File.find(opts[:attachmentId])
      _suggest.file = _file.to_attachment _suggest unless _file.blank?
    end
    _suggest.save
    _suggest
  end

end
