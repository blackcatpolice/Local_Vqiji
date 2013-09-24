# encoding: utf-8

# 工作组
class Group
  include Mongoid::Document
  include Mongoid::Timestamps
  include Handler::PinyinIndex
  include Mongoid::Paranoia

  NOTICE_MINLEN = 0
  NOTICE_MAXLEN = 140
	
	# fields
	field :name, :type => String # 名称
	field :notice,:type => String # 公告
	field :summary,:type => String # 工作组简介
	belongs_to :department, :class_name => 'Department', inverse_of: :_group

  field :quitable, :type => Boolean, :default => true # 是否可以退出

	field :tweets_count,:type => Integer,:default => 0 # 微博数量

	belongs_to :creator, :class_name => 'User'	# 创建者
	has_many   :members, :class_name => 'GroupMember', inverse_of: :group, :dependent => :destroy # 包含成员
	field :members_count, :type => Integer, :default => 0 # 成员数量
	
  has_many :feeds, class_name: 'Gfeed', inverse_of: :group, dependent: :destroy

	validates_presence_of :name
	# validates_presence_of :creator


  include Sunspot::Mongo

  searchable do
    text :name
    text :notice
    text :summary
  end
  
  after_create do |group|
    group.join(group.creator, true) if group.creator # 将创建人添加为成员和管理员
  end

  # 小组成员
  def member_user_ids
  	members.only(:user_id).collect { |m| m.user_id.to_param }
  end

  # 是否包含某个用户
  def get_member(user)
    members.where(:user_id => user.to_param).first
  end

  def has?(user)
    members.where(:user_id => user.to_param).exists?
  end

  def joins(user_ids)
    exists_ids = members.where(:user_id.in => user_ids).distinct(:_id)
    User.where(:_id.in => (user_ids - exists_ids)).each do |user|
  	  join(user)
  	end
  end
  
  def join(user, is_admin = false)
    member = GroupMember.new(:group_id => self.id, :user_id => user.to_param)
    member.is_admin = is_admin
    member.save
  end
  
  def remove_member!(user)
    member = members.where(:user_id => user.to_param).first
    if member
      if (members_count <= 1)
        member.destroy
        self.delete
      else
        member.is_admin ? cancel_admin(user, true) : member.destroy
      end
    end
  end

  def admins
    members.admin_scope
  end

  def admins_count
    members.admin_scope.count
  end

  def admin_users(limit = 4)
    User.where(:_id.in => members.where(:is_admin => true).limit(limit).distinct(:user_id))
  end
  
  def has_admin?(user)
    members.where(:user_id => user.to_param, :is_admin => true).exists?
  end
  
  def set_admin(user)
    member = members.where(:user_id => user.to_param).first
    if (member)
      member.update_attribute(:is_admin, true)
    else
      join(user, true)
    end
  end
  
  def cancel_admin(user, remove = false)
    member = members.where(:user_id => user.to_param).first
    if (member && member.is_admin)
      if (admins_count > 1)
        remove ? member.destroy : member.update_attribute(:is_admin, false)
      else
        raise WeiboError, '不能删除最后一个管理员！'
      end
    end
  end

  class << self
    #用户所在组id
    def get_group_ids_by_user_id(user_id)
      GroupMember.where(:user_id => user_id)
        .only(:group_id).collect do |m|
          m.group_id.to_param
        end
    end

    def find_by_id(id)
      where(:_id => id).first
    end

    alias :get :find_by_id
  end
end
