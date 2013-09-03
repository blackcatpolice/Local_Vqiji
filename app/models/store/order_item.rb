# encoding: utf-8
# suxu
#商店的订单项目
class Store::OrderItem
  ##
  include Mongoid::Document
  include Mongoid::Timestamps
  ##
  belongs_to :order, class_name: 'Store::Order'
  ##
  belongs_to :product, class_name: 'Store::Product'
  ##
  mount_uploader :image, ProductImageUploader
  ##
  field :order_id,type:String #订单ID
  field :user_id,type:String #用户ID
  field :product_id,type:String ##商品ID 
  field :product_no,type:String ##商品编号 ,product.serial_no
  field :name,type:String #商品名称
  field :type,type:String #商品类型
  field :end_date,type:Date #商品兑换截止时间
  field :price,type: Integer #商品价格，积分
  field :quantity ,type:Integer #购买数量
  field :unit,type:String #商品单位
  field :subtotal,type:Integer #小计
  field :detail,type: String #商品详细
  field :style,type:String #商品款式
  field :cart_key,type:String #购物车中的key
  field :post,type:Boolean,default:false  #是否邮购
  field :postage,type:Integer #邮费
  field :postage_unit,type:Integer,default:1 #邮费单位
  field :pickup,type:String #取货说明
  field :postage_total,type:Integer,default:0 #邮费总计
  ##
  ##订单对应的商品信息
  def pro
    Store::Product.find(self.product_id)
  end
  
  def post_msg
    return "邮费每#{self.postage_unit}#{self.unit}#{self.postage}积分"
  end
  
  ##根据商品初始化订单项
  def self.create_by_product
    
  end
end
