# encoding: utf-8
#

#
# 微博评论
#
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Created # 评论时间

  # comment limits
  TEXT_MAXLEN = 140

  field :text, type: String #评论文本
  # 被评论的 tweet
  belongs_to :tweet, inverse_of: :comments, counter_cache: true
  # 评论人
  belongs_to :sender, class_name: 'User', inverse_of: :comments, counter_cache: true
  
  # 录音
  embeds_one :audio, class_name: 'Attachment::Audio'
  embeds_many :rtext, class_name: 'Rt::Token'
  # 微博发送人 (cache)
  belongs_to :tweeter, class_name: 'User', inverse_of: :revcomments
  
  # 被回复的评论
  belongs_to :refcomment, class_name: 'Comment', inverse_of: :replys, counter_cache: true
  # 被回复评论的人 (cache)
  belongs_to :refsender, class_name: 'User', inverse_of: nil
  
  # 收到的评论
  has_many :replys, class_name: 'Comment', inverse_of: :refcomment
  field :replys_count, type: Integer, default: 0
  
  # 提到
  has_many :mentions, as: :target, dependent: :destroy, autosave: true
  
  # 只读字段
  attr_readonly :text, :sender, :tweet, :audio, :rtext, :tweeter, :refsender
  
  validates :sender, presence: true, on: :create
  validates :tweet,  presence: true, unless: ->(comment) { comment.reply? }, on: :create
  validates :text,   presence: true, text_length: { maximum: TEXT_MAXLEN }, on: :create

  before_create do |comment|
    if reply?
      comment.tweet = comment.refcomment.tweet
      comment.refsender = comment.refcomment.sender
    end
    comment.tweeter = comment.tweet.sender
    # 解析 text
    comment.rtext = Comment::Rtext.tokenize(comment.text)
    # 设置提到 (剔除发送人自己和被回复的人)
    _mention_ids = [ comment.sender_id, comment.refsender_id ]
    comment.rtext.each do |rt|
      if rt.kind_of?(Rt::Met) && !_mention_ids.include?(rt.uid)
        _mention_ids << rt.uid
        comment.mentions.new(:user_id => rt.uid)
      end
    end
  end

  index :sender_id => 1
  index :tweet_id => 1
  index :tweeter_id => 1
  index :refsender_id => 1
  index :created_at => -1
  index :sender_id => 1, :tweet_id => 1
  index :sender_id => 1, :tweeter_id => 1
  index :sender_id => 1, :tweet_id => 1, :created_at => -1
  
  # index of mention
  index('rtext._type' => 1, 'rtext.uid' => 1)
  
  # 提到的用户
  scope :mention_user, ->(user_id) { where('rtext.uid' => user_id, 'rtext._type' => 'Rt::Met')}
  # 默认排序(时间倒序)
  default_scope desc(:created_at)

  def set_audio(audio_id)
    _audio = Attachment::Audio.get(audio_id)
    if (_audio)
      _audio.update_attributes(:target => self)
      self.audio = _audio
    end
  end

  def reply?
    !!(refcomment_id || refcomment)
  end
  
  # 回复评论
  def reply(commenter, text, refcomment)
    Comment.create!(sender: commenter, text: text, refcomment: refcomment)
  end
  
  class << self
    def find_by_id(id)
       where(_id: id).first
    end
    
    alias :get :find_by_id
    
    def find_received_by(user_id)
      where(
        :sender_id.ne => user_id,
        '$or' => [
          { :tweeter_id => user_id },
          { :refsender_id => user_id }
        ]
      )
    end
  end

  module Rtext
    class << self
      def tokenize(text)
        Rt.tokenize(text.gsub('\n', ' '), [Rt::Emo, Rt::Met, Rt::Txt])
      end
    end
  end
end
