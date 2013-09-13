# encoding: utf-8

class User
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  include Mongoid::Timestamps
  include Handler::PinyinIndex

  GENDER_MALE = 0
  GENDER_FEMALE = 1
  
  STATUS_DISABLE = 0
  STATUS_ENABLE = 1

  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable,
         :authentication_keys => [ :login ]
  
  # Virtual attributes
  attr_accessor :login
  
  ## devise fields
  ## Database authenticatable
  field :email,              :type => String
  field :encrypted_password, :type => String, :default => ''
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time
  ## Rememberable
  field :remember_created_at, :type => Time
  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  # devise fields end
  
  # 基本信息 
  field :name,     :type => String # 名字
  belongs_to :department, :class_name => 'Department', inverse_of: :members, counter_cache: true # 部门
  field :is_admin,  :type => Boolean,:default => false #是否为管理员
  field :birthday, :type => Date   # 生日
  field :gender,   :type => Integer, :default => GENDER_MALE # 性别
  belongs_to :from, :class_name => 'City' # 来至 （出生地/所在地）
  
  mount_uploader :avatar, AvatarUploader # 头像

  field :job_no, :type => String #员工号 登录字段
  field :job, :type => String #职位
  field :phone, :type=> String #电话
  field :id_number, :type => String #身份证号码
  field :jifen, :type=>Integer,:default => 0 #用户积分

  field :check_at, :type => Time # 激活
  field :status,     :type => Integer, :default => STATUS_ENABLE # 用户状态

  field :is_expert, :type => Boolean, :default => false # 专家
  has_one :expert, :class_name => 'Expert', :inverse_of => :user
  field :release_public_knowledge, :type => Boolean, :default => false  # 默认没有发布公开文档的权限
  
  validates :name, presence: true, format: { with: /\S+/ }, uniqueness: true
  validates :job_no, uniqueness: true, allow_nil: true
  validates :email, uniqueness: true, allow_nil: true

  # [ :user, :admin ] allowed
  attr_accessible :password, :password_confirmation, :gender, :avatar,
    :birthday, :from, :from_id, as: [:user, :admin]

  # [ :admin ] allowed
  attr_accessible :email, :name, :job, :job_no, :id_number, :jifen, :status,
    :department, :department_id, :check_at, :is_admin, :is_expert,
    :release_public_knowledge, as: [:admin]

  scope :fuzzy_search_by_name, ->(query) {
    reg = /^#{ Regexp.escape(query) }/i
    where('$or' => [
      { name: reg },
      { pinyin_name: reg }
    ])
  }
  
  # 已经验证
  scope :checked, where(:check_at.ne => nil)
  scope :enabled, where(:status  => STATUS_ENABLE)
  
  def checked?
    !!check_at
  end
  
  alias :email_required? :checked?
  
  class << self
    # 根据 email 和  job_no 登录
    def find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        login_reg = /^#{ Regexp.escape(login) }$/i
        checked.where(
          :'$or' => [
            { email: login_reg },
            { job_no: login_reg }
          ],
        ).first
      else
        where(conditions).first
      end
    end
    
    def find_by_id(id)
      where(:_id => id).first
    end

    def find_by_name(name)
      where(name: name).first
    end
  end
  
  # === 工作组 ===

  has_many :group_members, class_name: 'GroupMember', inverse_of: :user, dependent: :destroy
  field :groups_count, :type=> Integer, :default => 0 # 工作组数量
  has_many :gfeeds, class_name: 'Gfeed', inverse_of: :_sender, dependent: :destroy

  def groups
    Group.where(:_id.in => group_members.distinct(:group_id))
      .includes(:department)
  end

  # === 微博 ===
  # 微博
  has_many :tweets, class_name: 'Tweet', inverse_of: :sender, dependent: :destroy
  field :tweets_count,  type: Integer, default: 0 #微博数量
  # 评论
  has_many :comments, class_name: 'Comment', inverse_of: :sender, dependent: :destroy
  field :comments_count, type: Integer, default: 0 #评论数量
  # 收到评论
  has_many :revcomments, class_name: 'Comment', inverse_of: :refsender, dependent: :nullify
  field :revcomments_count, type: Integer, default: 0 #收到的评论数
  
  # 收到的微博
  # has_many :feeds, includes: [:sender, :tweet], sort: 'created_at DESC', dependent: :destroy
  
  def feeds
    Feed.find_by_receiver_id(id).includes( :sender, :tweet ).desc(:created_at)
  end
  
  after_destroy do |user|
    user.feeds.destroy_all
  end
  
  # 收到的评论
  def received_comments
    Comment.find_received_by(id)
  end
  
  # 发布微博
  def tweet(opts)
    group_member = opts[:groupId] && group_members.where(:group_id => opts[:groupId]).first
    
    tweet = tweets.create!(:text => opts[:text]) do |tweet|
      tweet.group = group_member.group if group_member  # 工作组
      
      if opts[:reforigin] # 转发
        raise WeiboError, '不能转发该微博！' unless opts[:reforigin].repostable?
        tweet.reforigin = opts[:reforigin]
      else
        tweet.set_audio attachments.audios.find(opts[:audioId]) if opts[:audioId]
        tweet.set_picture attachments.pictures.find(opts[:pictureId]) if opts[:pictureId]
        tweet.set_file attachments.find(opts[:fileId]) if opts[:fileId]
      end
      
      # 设置分发策略大厅
      tweet.is_top = opts[:is_top]
      tweet._to_fans = opts[:to_fans] unless tweet.is_top
      tweet.group_ids = group_members.where(:group_id.in => opts[:group_ids]).distinct(:group_id) if opts[:group_ids] # 分发到的组
    end

    # 分发到我的微博 feed 列表中
    tweet.dispatch_to_user(self) if tweet.to_fans?
    tweet.dispatch_to_group(group_member.group, :is_top => group_member.is_admin) if group_member

    # 放到消息队列
    Resque.enqueue(Tweet::Dispatcher, tweet.id)
    tweet
  end

  # 转发微博
  def repost(tweet, text)
    _tweet = tweet(text: text, reforigin: tweet)
    # 创建提到
    if (tweet.sender != self)
      Mention.create(:uid => tweet.sender_id, :target =>  _tweet)
    end
    _tweet
  end
  
  # 删除微博
  def delete_tweet!(tweet)
    if (tweet.sender_id != id)
      raise WeiboError.new('您无权删除这条微博！')
    end
    tweet.destroy
  end

  #发送评论
  def send_comment(params)
    comment = Comment.new(:sender => self, :text => params[:text])
    # 设置回复
    if (recomment_id = params[:recomment_id])
      refcomment = Comment.get(recomment_id)
      raise WeiboError.new('原评论被删除，不能进行回复') unless refcomment
      comment.refcomment = refcomment
    else
      tweet = Tweet.find(params[:tweet_id])
      raise WeiboError.new('原微博被删除，不能进行回复') unless tweet
      comment.tweet = tweet
    end
    #评论的语音
    comment.set_audio(params[:audioId])
    comment.save!
    return comment
  end
  
  # 删除评论
  def delete_comment!(comment)
    if (comment.sender_id != id)
      raise WeiboError, '您无权删除这条评论！'
    end
    comment.destroy
  end
  
  # === 提到 ===
  has_many :mentions, :inverse_of => :user, dependent: :destroy
  # field :mentions_count, :type => Integer, :default => 0 # 被提到次数

  # === 临时文件 ===
  
  # 删除临时文件
  def delete_tmp!(tmp)
    unless (id == tmp.uploader_id)
      raise WeiboError.new('您无权删除这个临时文件！')
    end
    tmp.destroy
  end

  include Followship::UserExtends
  include Favorite::UserExtends
  include Talk::UserExtends
  include Todo::UserExtends
  include Schedule::UserExtends
  include Notification::UserExtends
  include Attachment::UserExtends
  
  def to_builder
    Jbuilder.new do |json|
      json.(self, :id, :name)
    end
  end
end
