# encoding: utf-8

class Talk::Message
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  store_in :collection => 'talk_messages'
  
  belongs_to :group, class_name: 'Talk::Group', inverse_of: :messages, counter_cache: true
  has_many :feeds, class_name: 'Talk::Feed', inverse_of: :message, dependent: :destroy

  # validations
  validates_presence_of :group, on: :create
  
  # indexes
  index :group_id => 1
  
  # scopes
  default_scope desc(:created_at)
  
  attr_readonly :group
  
  # 系统消息？
  def sys?
    is_a? Talk::Message::Sys
  end
  
  def feed_for(user)
    feeds.where(receiver_id: user.to_param).first
  end
  
  def session
    @_session ||= group.session_for(sender)
  end
  
  def dispatch!
    sessions = group.sessions.where(:user_id.nin => dispatch_expect_user_ids)
    # 批量插入消息 (绕过 Feed 的 validations / callbacks 加快写入速度)
    batch = sessions
      .distinct(:user_id).collect do |user_id|
        {
          receiver_id: user_id,
          message_id: id,
          group_id: group_id,
          created_at: created_at.utc
        }
      end
    # 发送给自己，并标记为已读
    dispatch_readed_user_ids.each do |user_id|
      batch << {
        receiver_id: user_id,
        message_id: id,
        group_id: group_id,
        created_at: created_at.utc,
        is_read: true
      }
    end
    Talk::Feed.collection.insert(batch)
    Talk::Session.where(:_id.in => sessions.distinct(:_id))
      .update_all({
        '$set' => { :updated_at => created_at.utc },
        '$inc' => { :unread_count => 1 }
      })
    if is_a? Talk::Message::User
      # 修改发送人的会话最后更新时间以排序会话
      session.update_attributes(:updated_at => created_at.utc)
    end
  end

  protected
  
  def dispatch_expect_user_ids
    []
  end
  
  def dispatch_readed_user_ids
    []
  end
  
  module Talk::Rtext
    def self.tokenize(text)
      Rt.tokenize(text.gsub('\n', ' '), [Rt::Emo, Rt::Url, Rt::Txt])
    end
  end
end

# 预加载 Talk::Message::User 防止发生 Talk::Message::User => ::User 的错误
require 'talk/message/user'
require 'talk/message/sys'
