# encoding: utf-8
#用户校验模型
class Check
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name ,:type => String #姓名
  field :job_no, :type => String #工号
  field :id_number,:type => String  #身份证号
  field :session_id, :type => String # session id
  field :use_count, :type => String # 使用次数
  field :ip,:type => String #IP 地址
  field :used,:type => Boolean, :default => false #是否使用
  field :messages,:type=>Hash, :default => Hash.new

  belongs_to :user,:class_name=>"User"
  
  validates_presence_of :name,:job_no,:id_number

  #
  def self.find_by_id cid
    return Check.where(:_id=>cid).first
  end

  #
  def get_message(key)
    return self.messages[key].join(",") if self.messages.has_key? key
  end

  #执行检查 => 检查通过创建数据
  def execute
    unless self.valid?
      self.messages = self.errors.messages
      return false
    end
  	self.user = user = 	User.where(:job_no=>self.job_no,:id_number=>self.id_number,:name=>self.name).first
    self.messages[:user] = ["没用找到对应的用户"] if user.blank?
    return false if self.messages.any?
    self.messages[:user] = ["该用户已经注册"] if user.checked
    return false if self.messages.any?
    self.save
    return true
  end

  # 激活用户 => 修改用户数据
  def active(opts)
    user = self.user
    return false if user.blank?
    user.email = opts[:user][:email]
    user.password = opts[:user][:password]
    user.password_confirmation = opts[:user][:password_confirmation]
    user.valid?
    self.messages = user.errors.messages
    self.messages["user"] = ["用户已经注册"] if user.checked
    self.save
    return false if self.messages.any?
    user.checked = true
    user.save
    return user
  end
end
