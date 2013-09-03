class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  # 回复内容 追问内容
  field :text
  field :incognito, type: Boolean, default: true    #匿名
  embeds_one :audio,  :class_name => 'Attachment::Audio'
  belongs_to :replier, :class_name => 'User'
  belongs_to :expert, :class_name => 'Expert'
  belongs_to :question, :class_name => 'Question', :inverse_of => :answers
  belongs_to :question_owner, :class_name => 'User'  #提问人

  validates :replier, :question, :presence => true
  
  index :replier_id => 1
  index :question_id => 1
  
  before_create do |answer|
    answer.question_owner = answer.question.owner
  end

  after_create :update_by_after_create
  
  def update_by_after_create
    question = self.question
    question.allow_delete = false if self.replier_id != self.question_owner_id
    if self.question_owner_id != self.replier_id
      question.expert_replys += 1 
      question.replied_at = Time.now
    else
      question.owner_replys += 1 
      question.replied_at = Time.now
    end
    question.save
  end
  
  def set_audio audio_id
    return if audio_id.blank?
    _audio = Attachment::Audio.get(audio_id)
    return if _audio.blank?
    _audio.target = self
    _audio.save
    self.audio = _audio
  end
  
  def is_expert
    self.replier_id != self.question_owner_id
  end
end
