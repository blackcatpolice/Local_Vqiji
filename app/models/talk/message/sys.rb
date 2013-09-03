# encoding: utf-8

# 系统消息
class Talk::Message::Sys < Talk::Message
  TYPE_USER_JOIN = 0 # 用户加入
  TYPE_USER_QUIT = 1 # 用户退出
  
  field :type
  belongs_to :actor, class_name: 'User'
  
  validates :type, presence: true, inclusion: { in: [ TYPE_USER_JOIN, TYPE_USER_QUIT ] }
  validates :actor, presence: true

  attr_readonly :type, :actor
  
  class << self
    def build_join(user, group)
      new(:actor => user, :group => group, :type => TYPE_USER_JOIN)
    end
    
    def build_quit(user, group)
      new(:actor => user, :group => group, :type => TYPE_USER_QUIT)
    end
  end # /ClassMethods
  
  protected
  
  def dispatch_expect_user_ids
    [ actor_id ]
  end
  
  def dispatch_readed_user_ids
    []
  end
end
