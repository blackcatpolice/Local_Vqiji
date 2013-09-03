class Talk::Session
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  
  belongs_to :user, class_name: 'User', inverse_of: :talk_sessions
  belongs_to :group, class_name: 'Talk::Group', inverse_of: :sessions, counter_cache: true

  # 邀请人
  belongs_to :inviter, class_name: 'User', inverse_of: nil

  # unread
  field :unread_count, type: Integer, default: 0

  # helper fields
  field :_p2p, type: Boolean, default: false
  belongs_to :_group_creater, class_name: 'User', inverse_of: nil # 组创建人

  # readonly fields
  attr_readonly :group, :user, :inviter, :_p2p, :_group_creater

  # validations
  validates :group, presence: true
  validates :user, presence: true, uniqueness: { scope: :group_id }
  
  before_create do |session|
    session._p2p = session.group.p2p
    session._group_creater = session.group.creater
  end

  after_create :realtime_notify_created
  after_destroy :realtime_notify_destroyed
  
  # indexes
  index :user_id => 1
  index :user_id => 1, :updated_at => -1
  index :group_id => 1
  index :group_id => 1, :unread_count => -1
  index :group_id => 1, :updated_at => -1
  index :group_id => 1, :unread_count => -1, :updated_at => -1
  index({ :user_id => 1, :group_id => 1 }, unique: true)
  index(:user_id => 1, :group_id => 1, :updated_at => -1)

  # scopes
  default_scope desc(:unread_count, :updated_at)

  # notifications triggers
  def realtime_notify_created
    Talk::Realtime::TalkSessionCreatedTrigger.notify(self)
  end

  def realtime_notify_destroyed
    Talk::Realtime::TalkSessionDestroyedTrigger.notify(self)
  end

  #
  delegate :topic, :messages, :to => :group
  
  def p2p?; _p2p; end
  
  def creater?
    user_id == _group_creater_id
  end
  
  def feeds
    Talk::Feed.where(receiver_id: user_id, group_id: group_id)
  end
  
  # 发送消息
  def say(text, opts = {})
    group.send_message(user, text, opts)
  end
  
  def read(feeds)
    feeds = Array.wrap(feeds).select do |feed|
      (feed.group_id == group_id) && !feed.is_read
    end

    unread_ids = feeds.collect &:id
    if unread_ids.any?
      self.feeds.where(:_id.in => unread_ids).update_all(is_read: true)
      inc(:unread_count, - unread_ids.count)
    end
  end
  
  def reset_unread_count!
    feeds.unread.update_all(:is_read => true)
    update_attribute(:unread_count, 0)
  end
  
  # Paranoia Overwrite
  
  def delete
    super
    feeds.destroy_all # 删除所有的聊天记录
    realtime_notify_destroyed
    true
  end
  
  def restore
    super
    realtime_notify_created
    true
  end
end
