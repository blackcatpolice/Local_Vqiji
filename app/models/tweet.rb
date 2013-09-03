# encoding: utf-8
#
# 微博
#
# 微博是由 140 个多字节字符（单字节字符为 280）组成的简短信息
# 微博正文可以包含一下信息：
#  * 普通文本，如: 我是小明
#  * 表情，如: [笑]
#  * 话题，如: #话题飘过#
#  * 链接，会被转换为短链接, 如: http://126.am/D3aE~，
#    链接主要分为 ‘视频链接‘，’音乐链接‘ 和 ‘普通链接’
#  * 提到, 如: "@bmm "
#
# 同时微博中还允许若干附件：
#   * 图片
#   * 录音
#   * 视频
#   * 其他文件
#   * 另外一条微博的引用(转发)
#
# 微博可以被转发，被评论

class Tweet
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  TEXT_MAXLEN = 140

  field :text # 博文
  belongs_to :sender, :class_name => 'User', :inverse_of => :tweets, :counter_cache => true# 发送人
  belongs_to :group, :class_name => 'Group', inverse_of: nil # 所属组

  embeds_many :rtext, class_name: 'Rt::Token'  # 博文序列

  # 附件
  embeds_one :file, class_name: 'Attachment::File' #文件
  embeds_one :picture, class_name: 'Attachment::Picture'  #图片
  embeds_one :audio, class_name: 'Attachment::Audio' #录音

  # 转发
  belongs_to :reforigin, :class_name => 'Tweet', inverse_of: nil # 引用的微博

  field :refchain, :type => Array # 引用链
  field :reposts_count, type: Integer, default: 0 # 转发数量
  belongs_to :reftweet, :class_name => 'Tweet', inverse_of: nil # 引用目标微博
  
  # 获取转发该微博的微博
  def reposts
    Tweet.where(:refchain => id)
  end

  # 分发策略设置
  field :is_top, :type => Boolean, :default => false # 重要微博
  field :group_ids, :type => Array # 推送的工作组
  
  # 只读字段
  attr_readonly :text, :sender, :group, :rtext, :file, :picture, :audio,
   :regorigin, :refchain, :reftweet, :is_top, :group_ids

  has_many :feeds, inverse_of: :tweet, dependent: :destroy # feeds
  has_many :gfeeds, class_name: 'Gfeed', inverse_of: :tweet, dependent: :destroy
  has_many :mentions, as: :target, dependent: :destroy, autosave: true # 提到

  # 评论
  has_many :comments, inverse_of: :tweet, dependent: :destroy
  field :comments_count, type: Integer, default: 0

  # 收藏
  has_many :favorites, :inverse_of => :tweet, :dependent => :destroy
  field :favorites_count, :type => Integer, :default => 0

  # validations
  validates :text, :presence => true, :text_length => { :maximum => TEXT_MAXLEN }

  # callbacks
  before_create do |tweet|
    # 设置引用链
    if (reforigin = tweet.reforigin)
      if reforigin.refchain.blank?
        tweet.refchain = [reforigin.id]
      else
        tweet.refchain = ([reforigin.id] + reforigin.refchain).uniq
      end
      tweet.reftweet = (reforigin.reftweet || reforigin)
    end
    
    # 解析 text
    tweet.rtext = tweet.repost? ? Rtext.tokenize_repost(tweet.text) : Rtext.tokenize(tweet.text)

    # 设置提到
    _mention_ids = [ tweet.sender_id ]
    tweet.rtext.each do |rt|
      if rt.kind_of?(Rt::Met) && !_mention_ids.include?(rt.uid)
        _mention_ids << rt.uid
        tweet.mentions.new(:user_id => rt.uid)
      end
    end
  end
  
  after_create do |tweet|
    # Tweet.refchain_count + 1
    unless tweet.refchain.blank?
      Tweet.where(:_id.in => tweet.refchain).inc(:reposts_count, 1)
    end
    
    # Group.tweets_count + 1
    # if tweet.group || tweet.group_ids
    #  _ids = tweet.group ? [tweet.group.id] : []
    #  _ids += tweet.group_ids if tweet.group_ids
    #  if _ids.any?
    #    Group.where(:_id.in => _ids).inc(:tweets_count, 1)
    #  end
    # end
  end
  
  after_destroy do |tweet|
    # Tweet.refchain_count - 1
    unless tweet.refchain.blank?
      Tweet.where(:_id.in => tweet.refchain).inc(:reposts_count, -1)
    end
    
    # Group.tweets_count - 1
    #if tweet.group || tweet.group_ids
    #  _ids = tweet.group ? [tweet.group.id] : []
    #  _ids += tweet.group_ids if tweet.group_ids
    #  if _ids.any?
    #    Group.where(:_id.in => _ids).inc(:tweets_count, -1)
    #  end
    #end
  end

  # indexes
  index :sender_id => 1
  index :created_at => -1
  index :sender_id => 1, :created_at => -1
  index :group_ids => 1
  index :refchain => 1
  
  # index of mention
  index 'rtext._type' => 1, 'rtext.uid' => 1
  
  public

  scope :until, ->(datetime) { where(:created_at.lte => datetime) }
  scope :since, ->(datetime) { where(:created_at.gte => datetime) }
  
  # 提到指定话题的微薄
  scope :reference_topic, ->(title) { where('rtext.title' => title, 'rtext._type' => 'Rt::Tpr') }
  # 提到的用户
  scope :at_user, ->(user_id) { where('rtext._type' => 'Rt::Met', 'rtext.uid' => user_id) }  
  # 提到指定用户的微博
  scope :mention_user, ->(user_id) { where('rtext._type' => 'Rt::Met', 'rtext.uid' => user_id) }
  
  # 粉丝可见的微博
  scope :to_fans, where(:is_top.ne => true)
  # 可转发的微博
  scope :repostable, where(:is_top.ne => true)
  # 转发微博
  scope :repost, where(:reforigin_id.ne => nil)
  # 原创微博
  scope :original, where(:reforigin_id => nil)

  # 默认排序
  default_scope desc(:created_at)

  def set_audio(audio_id)
    _audio = Attachment::Audio.get(audio_id)
    if _audio
      _audio.update_attributes(:target => self)
      self.audio = _audio
    end
  end

  def set_file(file_id)
    _file = Attachment::Base.get(file_id)
    if _file
      _file.update_attributes(:target => self)
      self.file = _file
    end
  end

  def set_picture(picture_id)
    _picture = Attachment::Picture.get(picture_id)
    if _picture
      _picture.update_attributes(:target => self)
      self.picture = _picture
    end
  end
  
  # 粉丝可见
  def to_fans?
    !is_top
  end

  # 可以转发？
  def repostable?
    !is_top
  end

  # 判断这条微博是否是转发
  def repost?
    !!(reforigin_id || reforigin)
  end

  # 分发
  def dispatch
    # 分发到粉丝
    if to_fans?
      fanships = sender.fanships.includes(:user)
      fanships.each do |fanship|
        dispatch_to_user(fanship.user, :follow_type => fanship.follow_type)
      end
    end
    
    sender.group_members
      .where(:group_id.in => ( group_ids - [ group_id ] )) # 排除已经在 User#tweet 中发送的组
      .includes(:group)
      .each do |group_member|
        dispatch_to_group(group_member.group, :is_top => group_member.is_admin)
      end unless group_ids.blank?
  end

  # 分发给用户
  def dispatch_to_user(user, options = {})
    Feed.create(
      :tweet => self,
      :follow_type => options[:follow_type] || Followship::FOLLOW_TYPE_DEFAULT,
      :receiver => user,
      :created_at => created_at
    )
  end
  
  # 分发到工作组
  def dispatch_to_group(group, options = {})
    gfeeds.create(:group => group) do |feed|
      feed.is_top = (is_top && options[:is_top]) if options.key?(:is_top)
      feed.created_at = created_at
    end
  end

  # 评论
  def comment(commenter, text)
    comments.create!(sender: commenter, text: text)
  end
  
  class << self
    def find_by_sender_id(user_id)
      where(:sender_id => user_id)
    end
    
    def find_by_id(id)
      where(_id: id).first
    end
    
    def query(options)
      tweets = Tweet.all
      # /a/ => 区分大小写 /a/i => 不区分大小写
      tweets = tweets.where(:text => /#{options[:keyword]}/i) unless options[:keyword].blank?
      tweets = tweets.where(:created_at.gte => options[:begin]) unless options[:begin].blank?
      tweets = tweets.where(:created_at.lte => (options[:end] + " 23:59:59")) unless options[:end].blank?
      tweets
    end
  end

  AS_JSON_BASIC_OPTS = {
    :only => [
      :text, :rtext, :created_at,
      :audio, :picture, :file,
      :reposts_count, :comments_count
    ],
    :methods => :id
  }
  
  AS_JSON_OPTS = {
    :include => {
      :sender => User::AS_JSON_OPTS
    }
  }.merge(AS_JSON_BASIC_OPTS)

  def as_json(options = nil)
    super(options || AS_JSON_OPTS)
  end
  
  module Rtext
    class << self
      def tokenize(text)
        Rt.tokenize(text.gsub('\n', ' '), [Rt::Tpr, Rt::Emo, Rt::Met, Rt::Url, Rt::Txt])
      end
      
      # 评论中不能加链接
      def tokenize_repost(text)
        Rt.tokenize(text.gsub('\n', ' '), [Rt::Tpr, Rt::Emo, Rt::Met, Rt::Txt])
      end
    end
  end
end
