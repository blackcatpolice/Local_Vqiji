#coding: utf-8

class Knowledge::Knowledge
  include Mongoid::Document
  include Mongoid::Timestamps
  include Handler::PinyinTitle

  EDITOR_PAGE_HTML = "<hr style=\"page-break-after: always;\" '=\"\" class=\"ke-pagebreak knowledge_page\">"

  CHECK_UNAUDITED = 1
  CHECK_AUDITED = 2
  CHECK_END = 3

  field :title, :type => String
  field :tags,  :type => String
  field :clicks,:type => Integer,  :default => 0
  field :contents_count,  :type => Integer,  :default => 0
  field :comments_count,  :type => Integer,  :default => 0
  field :checked_at, :type => Time
  field :check_status, :type => Integer, :default => CHECK_UNAUDITED

  belongs_to :creator, :class_name => 'User'
  belongs_to :group,   :class_name => 'Group'
  belongs_to :knowledge_type, :class_name => 'Knowledge::KnowledgeType', :inverse_of => 'knowledges'
  belongs_to :checked_user,  :class_name => 'User'

  has_many :contents, :class_name => 'Knowledge::KnowledgeContent', :counter_cache => true, :inverse_of => 'knowledge', :dependent => :destroy , :autosave => true 
  has_many :comments, :class_name => 'Knowledge::KnowledgeComment', :counter_cache => true, :inverse_of => 'knowledge', :dependent => :destroy , :autosave => true

  validates :title, :creator, presence: true

  scope :published, where(:check_status => CHECK_AUDITED)


  include Sunspot::Mongo

  searchable do
    text :title
    text :contents do |knowledge| 
       knowledge.contents.map { |knowledge_content| knowledge_content.content } 
    end 
    integer :check_status
  end


  def checked_by_user(user = nil, status = CHECK_AUDITED)
    raise "no user" unless user
    if self.group
      raise "not group admin user" unless user == self.group.creator
    end
    self.checked_user =  user
    self.check_status = status
    self.checked_at = Time.now
    self.save
  end

  def add_contents(contents_params)
    contents = contents_params[:content]
    contents = contents.split(Knowledge::Knowledge::EDITOR_PAGE_HTML)
    contents.each_with_index do |content, index|
      self.contents.new(:page_index => index, :content => content)
    end
  end


  
  # KNOWLEDGE_STATUS_PUBLISH = 1 #已发布
  # KNOWLEDGE_STATUS_DRAFT = 0  #草稿
  
  # #已发布的知识
  # scope :published, where(:status => KNOWLEDGE_STATUS_PUBLISH)
  
  # field :title, :type => String
  # field :clicks, :type => Integer, default: 0
  # field :status, :type => Integer, default: KNOWLEDGE_STATUS_DRAFT
  # field :public, :type => Boolean, default: true
  # # field :text, :type => String
  # has_many :contents, class_name: 'Knowledge::KnowledgeContent', inverse_of: :knowledge, dependent: :destroy, :counter_cache => true
  # field :contents_count, :type => Integer, :default => 0

  # belongs_to :creator, :class_name => 'User'
  # belongs_to :knowledge_type, :class_name => 'KnowledgeType'
  # belongs_to :group, :class_name => 'Group'
  
  # index :title => 1
  # index :knowledge_type_id => 1
  # index :creator_id => 1
  
  # before_save do
  #   self.text = self.text.gsub(/<[^><]*script[^><]*>/i,'') if self.text_changed?
  # end

  # include Sunspot::Mongo

  # searchable do
  #   text :title
  #   text :text
  #   text :pinyin_title
  #   boolean :public
  #   string :group_id
  #   string :creator_id
  #   string :knowledge_type_id
  #   time :created_at
  # end
end
