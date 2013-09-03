class Talk::Group
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :topic
  belongs_to :creater, class_name: 'User'
  field :p2p, type: Boolean, default: false # 私信(true)/讨论组(false)
  
  has_many :sessions, class_name: 'Talk::Session', inverse_of: :group, autosave: true, dependent: :destroy
  field :sessions_count, type: Integer, default: 0

  has_many :messages, class_name: 'Talk::Message', inverse_of: :group, dependent: :destroy
  field :messages_count, type: Integer, default: 0
  
  has_many :feeds, class_name: 'Talk::Feed', inverse_of: :group, dependent: :destroy
  
  validates_presence_of :creater, on: :create
  validates :topic, :presence => true, if: ->(group) { !group.p2p }, on: :create
  validate on: :create do
    # 私信会话最多只有两人
    errors.add(:sessions, '私信成员最多两人！') if p2p && (sessions.count > 2)
  end
  
  after_create do |group|
    # 自动添加创建人为成员
    group.add_member(group.creater)
  end

  index :creater_id => 1
  index :creater_id => 1, :sessions_id => 1
  
  attr_readonly :topic, :creater, :p2p
  
  scope :p2p, where(:p2p => true)
  default_scope desc(:created_at)
  
  # 私信会话？
  def p2p?
    p2p
  end
  
  # 多人会话
  def multi_member?
    sessions_count > 2
  end
  
  def has_member?(user)
    sessions.where(:user_id => user.to_param).exists?
  end
  
  def session_for(user, with_deleted = false)
    (with_deleted ? sessions.unscoped : sessions).where(:user_id => user.to_param).first
  end
  
  def can_add_member?
    (sessions.count < 2) || !p2p
  end

  def add_member(user, inviter = nil, save = true)
    raise Talk::Error, '不能为私信会话添加成员！' unless can_add_member?
    (session_for(user) || (save ? sessions.create!(user: user, inviter: inviter) : sessions.new(user: user, inviter: inviter)))
  end
  
  def remove_member!(user)
    if (session = session_for(user))
      p2p ? session.delete : session.destroy
    end
  end
  
  def remove_session!(session)
    if (session.group == self)
      p2p ? session.delete : session.destroy
    end
  end
  
  def restore_sessions!
    deleted_sessions = sessions.deleted
    deleted_sessions.each do |session|
      session.restore # 恢复删除的会话
    end if deleted_sessions.any?
  end
  
  # 发送消息
  def send_message(sender, text, opts={})
    _message = Talk::Message::User.new(group: self, sender: sender, text: text) do |message|
      message.set_picture(opts[:pictureId]) if opts[:pictureId]
      message.set_audio(opts[:audioId]) if opts[:audioId]
      message.set_file(opts[:fileId]) if opts[:fileId]
    end
    
    if _message.save!
      restore_sessions! if p2p
      # 为了实现及时聊天的及时性, 消息的分发同步执行
      _message.dispatch!
      realtime_notifiy_message_changed(sender)
    end
    _message
  end
  
  def notify_user_join(user, dispatch=true)
    message = Talk::Message::Sys.build_join(user, self)
    message.save!
    if dispatch
      message.dispatch!
      realtime_notifiy_message_changed(user)
    end
    message
  end
  
  def notify_user_quit(user, dispatch=true)
    message = Talk::Message::Sys.build_quit(user, self)
    message.save!
    if dispatch
      message.dispatch!
      realtime_notifiy_message_changed(user)
    end
    message
  end
  
  class << self
    def between(user, receiver)
      _ids = Talk::Session.unscoped.where(:user_id => user.to_param, :_p2p => true).distinct(:group_id) \
           & Talk::Session.unscoped.where(:user_id => receiver.to_param, :_p2p => true).distinct(:group_id)
      Talk::Group.p2p.where(:_id.in => _ids).desc(:created_at).first
    end # /between
    
    # 找（并恢复所有会话状态）或创建会话组
    def p2p_find_or_create_by(user, receiver)
      group = between(user, receiver)
      if group
        group.restore_sessions!
      else # 创建私信会话
        begin
          group = Talk::Group.new(creater: user, p2p: true) do |new_group|
            new_group.add_member(receiver, user, false)
          end
          group.save!
        rescue => e
          group.destroy if group && group.persisted?
          raise e
        end
      end
      group
    end # /p2p_find_or_create_by
  end # /Class Methods
  
  # 通知改组的监听者有新消息
  def realtime_notifiy_message_changed(trigger)
    Talk::Realtime::GroupMessageChangedTrigger.notify(self, trigger)
  end
end
