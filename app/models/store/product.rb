# encoding: utf-8
#
# suxu
#
#商品信息
class Store::Product
  include Mongoid::Document
  include Mongoid::Timestamps
  ##
  scope :all_scope,lambda{where()}#
  scope :type_scope,lambda{|type| where(:product_type => type)} #
  scope :exchange_scope,lambda{where(:exchange=>true)}
  scope :unexchange_scope,lambda{where(:exchange=>false)}
  #推荐商品
  scope :recommend_scope,lambda{where(:recommend=>true)}
 
  ##
  belongs_to :user,class_name: 'Usercpy'
  ##
  mount_uploader :image, ProductImageUploader
  mount_uploader :ad_image,ProductImageUploader
  ##
  field :serial_no,type:String # 商品序号
  field :name, type: String #名称
  field :product_type ,type:String #商品类型
  field :user_id,type:Integer #用户ID，商品创建者ID
  field :price,type: Integer #价格，积分
  field :begin_date,type:Date,default:Time.now #开始时间，默认当前时间
  field :end_date,type:Date,default:Time.now.ago(-100.days) #兑换截止时间,默认100天以后
  field :quantity ,type:Integer #当前数量
  field :unit,type:String #单位
  field :enable,type:Boolean ,default:true#是否启用
  field :image,type:String #商品图片，用于首页展示
  field :style_option,type:String #款式选项，颜色，大小，尺寸,材质 等
  field :styles,type:String # 款式： 如红色,白色,蓝色
  field :detail,type:String #详细
  field :temp,type:String # 临时字段
  field :direct,type:Boolean,default:true #直接兑换
  field :exchange,type:Boolean,default:true #是否直接兑换 true 可以直接兑换 false 只能报销消费
  field :post,type:Boolean,default:false  #是否邮购
  field :postage,type:Integer #邮费
  field :postage_unit,type:Integer,default:1 #邮费单位
  field :remark,type:String #备注
  field :pickup,type:String #取货说明
  #
  field :summary,type:String #摘要，简介
  field :recommend,type:Boolean,default:false #推荐
  field :is_ad,type:Boolean,default:false #广告
  field :ad_image,type:String #广告图片
  
  
  #
  before_create :generate_sequence
  
  def self.get id
     begin
      return find(id)
    rescue Mongoid::Errors::DocumentNotFound #
      return nil
    end
  end
  #
  def has_styles
    return !self.style_option.nil?
  end
  #00.
  def style_array
    return @style_array if @style_array
    @style_array = self.styles.split(" ")
  end
  #
  def to_hash
   hash = {:id => self.id.to_s, :name => self.name, :type => self.product_type, :price => self.price,:unit=>self.unit,:detail=>self.detail}
   return hash
  end
  #商品兑换是否超时
  def timeout
    return !(Time.now<self.end_date) 
  end
  
  def post_msg
    return "邮费每#{postage_unit}#{self.unit}#{self.postage}积分"
  end
  
  #是否可以交易
  def can_trade
    return self.enable && !self.timeout && self.quantity>0
  end
  
  #将商品信息转换为订单项
  def to_order_item
    order_item = Store::OrderItem.new(
      :product_id=>self.id,:name=>self.name,:price=>self.price,:unit=>self.unit,
      :detail=>self.detail,:product_no=>self.serial_no,:image=>self.image,
      :post=>self.post,:postage_unit=>self.postage_unit,:postage=>self.postage,:pickup=>self.pickup)
    return order_item
  end
  #  
  def self.query options 
    products = Store::Product.exchange_scope if options[:exc] == true
    products = Store::Product.unexchange_scope if options[:exc] == false
   
    products = products.type_scope(options[:type]) if options[:type]
    #products = products.desc("created")
    products = products.where(:enable => true) #
    products = products.desc(options[:order]) if options[:by] == "desc" && options[:order]
    products = products.asc(options[:order]) if options[:by] == "asc" && options[:order]
    return products
  end
  
  #
  private
  #生成序列号
  def generate_sequence
    self.serial_no = Sequence.product
  end
  
end
