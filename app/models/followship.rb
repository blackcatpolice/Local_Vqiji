# encoding: utf-8

# 关注关系
class Followship
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  FOLLOW_TYPE_WHISPER    = -1 # 悄悄关注
  FOLLOW_TYPE_DEFAULT    = 0  # 默认关注
  FOLLOW_TYPE_PARTICULAR = 1  # 特别关注

  belongs_to :user, class_name: 'User', inverse_of: :followships # 关注用户
  belongs_to :followed, class_name: 'User', inverse_of: :fanships # 被关注的用户

  field :follow_type, type: Integer, default: FOLLOW_TYPE_DEFAULT #关注类型 普通，悄悄，特别
  field :remark, type: String #备注

  validates :user, presence: true
  validates :followed, presence: true
  validates_uniqueness_of :followed_id, :scope => :user_id
  validates :follow_type, presence: true

  after_create do |followship|
    unless followship.whisper?
      followship.followed.inc(:fans_count, 1)
      followship.user.inc(:followeds_count, 1)
    end
  end
  
  after_destroy do |followship|
    unless followship.whisper?
      followship.followed.inc(:fans_count, -1)
      followship.user.inc(:followeds_count, -1)
    end
  end
  
  index :user_id => 1
  index :followed_id => 1
  index :user_id => 1, :followed_id => 1
  index :user_id => 1, :follow_type => 1
  index :user_id => 1, :created_at => -1
  index :followed_id => 1, :created_at => -1

  scope :has_remark, where(:remark.ne => nil)
  scope :except_whisper, where(:follow_type.ne => FOLLOW_TYPE_WHISPER)
  scope :by_follow_type, ->(follow_type){ where(follow_type: follow_type) }
  
  # 悄悄关注？
  def whisper?
    (follow_type == FOLLOW_TYPE_WHISPER)
  end
  
  class Error < WeiboError; end
  
  class Service
    attr_reader :user
    
    def initialize(user)
      @user = user
    end

    # 已关注？
    def following?(other, except_whisper = false)
      finder = @user.followships.where(:followed_id => other.to_param)
      (except_whisper ? finder.except_whisper : finder).exists?
    end
    
    # 获取关注状态
    def followed(other, except_whisper = false)
      finder = @user.followships.where(:followed_id => other.to_param)
      (except_whisper ? finder.except_whisper : finder).first
    end

    # 关注用户
    # == 参数：
    #   user: 被关注的用户 id
    #   options:
    #     follow_type: 组 id
    #     remark:   备注
    #
    def follow(other, options = {})
      raise Followship::Error, '不能关注自己！' if (@user == other)
      
      follow_type = options[:follow_type] || Followship::FOLLOW_TYPE_DEFAULT
      followship = @user.followships.where(:followed_id => other.to_param).first
      
      if (!followship || ((followship.follow_type != follow_type) and followship.destroy))
        # 新建新关系
        followship = @user.followships.create!(
          followed: other,
          follow_type: follow_type,
          remark: options[:remark] || (followship && followship.remark)
        )
      end
      followship
    end

    # 取消关注
    def unfollow!(other)
      @user.followships.where(followed_id: other.to_param).destroy_all
    end
  end # /Service
  
  module UserExtends
    def self.included(base)
      base.class_eval do
        # 我关注的人
        has_many :followships, class_name: 'Followship', inverse_of: :user
        field :followeds_count, :type => Integer, :default => 0
        
        # 关注我的人
        has_many :fanships, class_name: 'Followship', inverse_of: :followed
        field :fans_count,  :type => Integer, :default => 0

        def followship_service
          @_followship_service_ ||= Followship::Service.new(self)
        end
        
        delegate :followed, :following?, :follow, :unfollow!, :to => :followship_service
      end
    end
  end # /UserExtends
end
