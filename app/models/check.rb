# encoding: utf-8
#用户校验模型
class Check
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name ,:type => String # 姓名
  field :job_no, :type => String # 工号
  field :id_number,:type => String  # 身份证号

  belongs_to :user, :class_name => 'User'
  
  validates_presence_of :name, :job_no, :id_number
  
  def messages
    @_messages ||= {}
  end
    
  #
  def self.find_by_id(cid)
    Check.where(:_id => cid).first
  end

  #
  def get_message(key)
    messages[ key ].join(',') if messages.has_key?(key)
  end

  # 执行检查 => 检查通过创建数据
  def execute
    unless self.valid?
      self.messages = self.errors.messages
      return false
    end
  	self.user = user = 	User.where(:job_no=>self.job_no,:id_number=>self.id_number,:name=>self.name).first
    self.messages[:user] = [ '没用找到对应的用户' ] if user.blank?
    return false if self.messages.any?
    self.messages[:user] = [ '该用户已经注册' ] if user.checked?
    return false if self.messages.any?
    self.save
    return true
  end

  # 激活用户 => 修改用户数据
  def active!(opts)
    return false unless user
    (messages['user'] = [ '用户已经注册' ] and return false) if user.checked?

    user.email = opts[:email]
    user.password = opts[:password]
    user.password_confirmation = opts[:password_confirmation]
    user.check_at = Time.now.utc
    
    unless user.valid?
      messages = user.errors.messages
      return false
    end

    save!
    user.save!
    true
  end
end
