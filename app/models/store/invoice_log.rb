# encoding: utf-8
#
# suxu
#发票报销日志
class Store::InvoiceLog
  #
  include Mongoid::Document
  include Mongoid::Timestamps
  #
  scope :user_scope,lambda{|user_id|where(:user_id => user_id)}
  ##
  belongs_to :user, class_name: 'Usercpy'
  ##
  field :serial_no,type:String #序列号
  field :invoice_id,type:String #
  field :pass,type:Boolean #
  field :msg,type:String 
  field :user_id, type: String #购买用户
  
  #
  #before_create :generate_serial_no
  #
  private
  #生成序列号
  def generate_serial_no
    # 得到最大订单号
    ymd = Time.now.strftime("%Y%m%d")
    max_no = Store::Invoice.max("serial_no")
    num = 1001
    num = max_no[8,max_no.length].to_i+1 if !max_no.nil? && max_no[0,8] == ymd
    self.serial_no = "#{ymd}#{num}"
  end
  
end