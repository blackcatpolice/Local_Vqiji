class Proposal::Comment

  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :content
  belongs_to :commenter, class_name: 'User'  
	belongs_to :suggest, class_name: "Proposal::Suggest"
  
  embeds_many :rtext, class_name: 'Rt::Token'
  embeds_one :audio,  class_name: 'Attachment::Audio'

  # callbacks
  before_create do |c|
    c.rtext = Tweet::Rtext.tokenize(c.content.gsub("\n",""))
  end  


  def self._create opts = {}
    comment = self.new(:suggest_id => opts[:suggest_id], :content => opts[:content])
    unless opts[:audioId].blank?
      _audio = Tmp::Audio.get(opts[:audioId])
      comment.audio = _audio.to_attachment comment unless _audio.blank?
    end
    comment.save
    comment
  end

end
