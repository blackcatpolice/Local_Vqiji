# encoding: utf-8
#
# suxu
#发票
class Store::Invoice
  #
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  STEP_WEBSITE = 1
  STEP_DEPT = 2
  STEP_HR = 3
  STEP_SUCCESS = 4
  #
  mount_uploader :image, ProductImageUploader
  #
  scope :user_scope,lambda{|user_id|where(:user_id => user_id)}
  scope :website_scope,lambda{where(:step=>STEP_WEBSITE)} #
  scope :dept_scope,lambda{where(:step => STEP_DEPT )}#
  scope :hr_scope,lambda{where(:step => STEP_HR)} #
  scope :success_scope,lambda{where(:step => STEP_SUCCESS )} #
  scope :stop_scope,lambda{where(:stop=>true)} #
  scope :not_stop_scope,lambda{where(:stop=>false)} #
  ##
  belongs_to :user, class_name: 'Usercpy'
  belongs_to :product, class_name: 'Store::Product'
  has_many :logs, class_name: 'Store::InvoiceLog'
  ##
  field :serial_no,type:String #序列号
  field :product_id,type:String #商品ID
  field :product_type,type:String #商品类型
  field :product_name,type:String #商品名称
  field :price,type:Float #价格
  field :money,type:Integer #金额
  field :user_id, type:String #购买用户
  field :department_id,type:Integer
  field :reason,type:String #理由
  field :step,type:Integer,default:1 #当前步骤 1 网站审核中 2 部门审核中  3 人事审核中  4 审核通过申请完成
  field :stop,type:Boolean,default:false #是否停止
  field :stop_msg,type:String #
  
  validates_presence_of :product_type,:product_name
  validates_numericality_of :price,:money
  #判断当前时候为审批状态
  def can_audit
    return self.stop == false && (self.step == STEP_WEBSITE || self.step == STEP_DEPT || self.step == STEP_HR)
  end
  
  #
  def _save
     #raise "请填写完整有效数据" unless self.valid?
     raise "报销额度不能大于商品价格" if self.money > self.price
     user = User.find_by_id(self.user_id)
     raise "申请人不存在" if user.nil?
     raise "申请人积分不足" if user.jifen < self.money
     #申请部门为当前申请人部门
     self.department_id = user.department_id
     product = Store::Product.get(self.product_id)
     raise "商品不存在" if product.nil?
     self.image = product.image
     raise "扣除积分失败" unless user.update_attributes(:jifen=>user.jifen-self.money)
     self.save
  end
  
  #
  def _update options
    step = options[:step]
    self.step = step if step.to_i != 0
    self.stop = true if step.to_i == 0
    self.stop_msg = options[:msg] if self.stop
    invoice_log = Store::InvoiceLog.new(:invoice_id=>self.id,:pass=>!self.stop,:msg=>options[:msg],:user_id=>options[:user_id])
    invoice_log.save
    self.save
    #审核没有通过将还原用户积分
    if self.stop
      user = User.find(self.user_id)
      user.update_attributes(:jifen=>user.jifen+self.money)
      Notification::Base.create(:receiver_id=>user.id,:msg=>"报销单被拒绝",:url=>"/store/invoices/#{self.id}")  
    end
    
  end
  
  #
  before_create :generate_sequence
  private
  #生成序列号
  def generate_sequence
    self.serial_no = Sequence.invoice
  end
  #
  def errors_full_messages
    msgs = ""
    self.errors.full_messages.each do |msg|
      msgs = msgs + msg
    end
    return msgs
  end
  
end
