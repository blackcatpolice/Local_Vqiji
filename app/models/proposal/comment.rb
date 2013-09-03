#coding: utf-8
class Proposal::Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  
  #field :commenter_id, type: Integer
  AS_JSON_BASIC_OPTS = {
    :only => [
      :content, :rtext, :created_at, :suggest_id, :audio
    ],
    :methods => :id
  }
  
  AS_JSON_OPTS = {
    :include => {
      :commenter  => User::AS_JSON_OPTS,
    }
  }.merge!(AS_JSON_BASIC_OPTS)  
  
  field :content   
  
    # 评论人
  belongs_to :commenter, class_name: 'User'
  
  embeds_many :rtext, class_name: 'Rt::Token'	
  
  embeds_one :audio,  class_name: 'Attachment::Audio' 

  # callbacks
  before_create do |c|
    c.rtext = Tweet::Rtext.tokenize(c.content.gsub("\n",""))
  end  
  
	belongs_to :suggest, class_name: "Proposal::Suggest"
	
  def as_json(options = nil)
    super(options || AS_JSON_OPTS)
  end	
  
  
  public
  
  def self._create opts = {}
    comment = self.new(:suggest_id => opts[:suggest_id], :content => opts[:content])
    unless opts[:audioId].blank?
      _audio = Tmp::Audio.get(opts[:audioId])
      comment.audio = _audio.to_attachment comment unless _audio.blank?
    end
    comment.save
    comment
  end
	
	#commenter
#	def commenter
#		User.find(commenter_id.to_s)
#	end


end
