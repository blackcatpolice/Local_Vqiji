# encoding: utf-8
#
# suxu
#商店的订单
class Store::Order
  #
  include Mongoid::Document
  include Mongoid::Timestamps
  ##订单状态常量
  STATUS_FAIL = -1 #失败，拒绝
  STATUS_INIT = 0 #创建，初始化
  STATUS_SUBMIT = 1 #提交
  STATUS_SHIP = 2 #送货中
  STATUS_CONFIRM = 3  #确认收货
  STATUS_SUCCESS = 4 #成功
  ##
  scope :init_scope,lambda{status_scope STATUS_INIT}
  scope :submit_scope,lambda{status_scope STATUS_SUBMIT}
  scope :ship_scope,lambda{status_scope STATUS_SHIP}
  scope :confirm_scope,lambda{status_scope STATUS_CONFIRM}
  scope :success_scope,lambda{status_scope STATUS_SUCCESS}
  scope :status_scope,lambda{|status|where(:status=>status)}
  scope :user_scope,lambda{|user_id|where(:user_id => user_id)}
  
  ##
  belongs_to :user,class_name:'Usercpy' 
  belongs_to :content,class_name:'OrderContent' #联系方式
  belongs_to :ship,class_name:'Courier'
  
  has_many :items,class_name:"Store::OrderItem"
  
  
  ##
  field :order_no,type:String #订单号
  field :user_id, type:String  # 用户
  field :total,type:Integer,default:0 #总共花费
  field :address,type:String #地址
  field :address_detail,type:String #详细地址
  field :customer,type:String #收货人姓名
  field :code,type:String #邮编
  field :phone,type:String #手机
  field :telephone,type:String #电话
  field :status,type:Integer  #订单状态 -1 拒绝/失败 0 初始化，1 提交，, 2,送货中 ，3，确认收货 4 完成
  field :temp,type:String 
  field :submitted_at,type:Time #订单提交时间
  field :remark,type:String #订单备注
  field :reason,type:String #订单被拒绝的理由
  field :post,type:Boolean,default:false #是否邮递
  field :ship_no,type:String #出货序号，快递单号
  field :ship_time,type:Time #送货时间
  field :ship_company,type:String #快递公司
  field :ship_confirm,type:Time #收货确认时间
  field :ship_id,type:String #快递公司

  
  ##
  #根据当前用户的购物车结算，生成订单
  #cart 购物车,user_id 用户ID
  def self.checkout_by_cart! cart,user_id
    order = Store::Order.new(:user_id=>user_id,:status=>STATUS_INIT)
    #order.save
    total = 0
    cart.keys.each do |k|
      ps = k.split("#")
      product = Store::Product.find(ps[0])
      order_item = product.to_order_item #将商品转换为订单项
      order_item.order= order
      order_item.quantity = cart[k].to_i
      order_item.subtotal = order_item.price * order_item.quantity
      order_item.style = ps[1] if ps.length>1
      total = total + order_item.subtotal
      order_item.save
    end
    order.total = total
    order.save
    return order
  end
  
  def self.get_by_cart! cart
    order = Store::Order.new
    #order
  end
  
  #提交订单
  def _submit options
    user = User.find(self.user_id)
    raise "您的积分不足,不能提交订单" if user.jifen < self.total
    products = Array.new
    self.items.each do |item|
      product = item.product
      raise "#{product.name} 只有#{product.quantity}#{product.unit}" if product.quantity<item.quantity
    end
    #修改商品数量
    self.items.each do |item|
      product = item.product
      product.update_attributes(:quantity=>product.quantity-item.quantity)
    end
    self.status = Store::Order::STATUS_SUBMIT
    self.submitted_at = Time.now
    self.update_attributes(options[:store_order])
    #修改用户积分
    user.update_attributes(:jifen=>user.jifen-self.total)
    
    
  end
  
  def _update options
    status = options[:status].to_i
    self.status = status
    #发货时取得快递单号和快递公司信息
    self.ship_no = options[:ship_no] if self.status == STATUS_SHIP
    self.ship_id = options[:ship_id] if self.status == STATUS_SHIP
    #订单被拒绝时取得理由
    if self.status == STATUS_FAIL
      self.reason = options[:reason]
      user = User.find(self.user_id)
      user.update_attributes(:jifen=>user.jifen+self.total)
      Notification::Base.create(:receiver_id=>user.id,:msg=>"订单被拒绝",:url=>"/store/orders/#{self.id}")    
    end
    self.save
  end
  
   #创建订单时自动生存订单号
  before_create :generate_sequence
  private
  #生成订单号
  def generate_sequence
    self.order_no = Sequence.order
  end
  
end
