# encoding: utf-8

# 专家
class Question
  include Mongoid::Document
  include Mongoid::Timestamps

  REVIEW_GREAT = 1 # 满意
  REVIEW_GOOD = 2 # 一般

  embeds_one :picture,  class_name: 'Attachment::Picture' #图片
  embeds_one :audio,  class_name: 'Attachment::Audio' #录音
  #has_many :answers, class_name: "Answer", :dependent => :destroy
  
  field :title, type: String
  field :text, type: String                       #问题内容
  field :expert_read, type: Boolean, default: false
  field :clicks, type: Integer, default: 0        #总点击数
  field :case_history, type: Array                #病历
  field :solved, type: Boolean, default: false    #是否解决
  field :solved_at, type: Time
  field :review, type: Integer
  field :incognito, type: Boolean, default: true    #匿名
  field :allow_delete, type: Boolean, default: true #问题是否允许删除
  field :expert_replys, type: Integer, default: 0   #专家回复数, expert_replys > 0 专家回复问题
  field :owner_replys, type: Integer, default: 0    #提问人追问, owner_replys > 0 提问人有新的追问
  field :replied_at, type: Time, default: ->{ Time.now } #最新回复时间
  ######           提问人部分信息           #########
  field :info, type: Hash, default: nil
  
  belongs_to :question_type, :class_name => 'QuestionType'
  belongs_to :expert, :class_name => 'Expert' # 提问指定的专家
  belongs_to :owner, :class_name => 'User'    # 提问人
  has_many :answers, :class_name => 'Answer', :inverse_of => :question
  
  validates_presence_of :title, :owner, :expert, :question_type

  index :expert_id => 1
  index :owner_id => 1
  index :question_type => 1
  index :incognito => 1
  
  scope :solved, where(:solved => true)
  scope :unsolved, where(:solved => false)
  scope :find_by_question_type, ->(question_type_id) {
    where(:question_type_id => question_type_id)
  }
  
  def set_audio(audio_id)
    _audio = Attachment::Audio.get(audio_id)
    if _audio
      _audio.update_attributes(:target => self)
      self.audio = _audio
    end
  end
  
  def answer!( opts={} )
    raise WeiboError.new("问题已解决, 不能再回复!") if solved
    Answer.create! do |answer|
      answer.incognito = (opts[:replier_id] == owner_id ? incognito : false) #医生回复不匿名   
      answer.replier_id = opts[:replier_id]
      answer.question_id = id
      answer.question_owner_id = owner_id
      answer.expert_id = expert_id
      answer.text = opts[:text]
      answer.set_audio opts[:audio_id]
    end
  end

  def _destroy!
    unless allow_delete
      raise WeiboError.new("专家已回复问题，无法删除问题!")
    end
    destroy
  end
  
  def click(opts={})
    self.clicks += opts[:click] || 0
    self.expert_read = opts[:expert_read] if opts[:expert_read]
    self.expert_replys = opts[:expert_replys] if opts[:expert_replys]
    self.owner_replys = opts[:owner_replys] if opts[:owner_replys]
    self.save
  end
  
  def get_case_history
    Attachment::Base.find(self.case_history) if self.case_history
  end
  
  class << self
    def user_questions user_id
      Question.where(:owner_id => user_id)
    end
    
    def expert_question expert_id
      Question.where(:expert_id => expert_id)
    end
  end
end
