# encoding: utf-8
#购物车模型
class Cart
  include Mongoid::Document
  include Mongoid::Timestamps
  field :data,type:Hash,default:Hash.new #购物车数据
  belongs_to :user, class_name: 'Usercpy'
  field :_id
  
  #根据用户取得购物车
  def self.get user_id
    where(:_id => user_id).first || Cart.new(:_id => _id)
  end
  
    
  #放入数据
  def add_to_cart key,value
    value = 1 if value == ""
    self.data[key] = (self.data[key] ? self.data[key] : 0) + value.to_i if value.to_i > 0
    self.remove key if value.to_i == 0 #数量为0时移除
  end
  #放入数据
  def put key,value
    value = 1 if value == ""
    self.data[key] = value if value.to_i > 0
    self.remove key if value.to_i == 0 #数量为0时移除
  end
  
  #取得数据
  def get key
    return self.data[key]
  end
  
  #移除购物车
  def remove (keys)
    if keys.class == Array
      keys.each do |key|
        self.data.delete key
      end
    elsif keys.class == String
      self.data.delete keys
    end
    
  end
  
  #
  def clear
    self.update_attributes(:data=>Hash.new)
  end
  
  #判断购物车是否为空
  def empty?
    return self.data.nil? || self.data.size == 0
  end
  
  
  #根据购物车构造订单项
  def order_items
    order_items = Array.new
    self.keys.each do |k|
      ps = k.split("#")
      product = Store::Product.get(ps[0])
      if product
        order_item = product.to_order_item #将商品转换为订单项
        order_item.quantity = self.get(k).to_i
        order_item.subtotal = order_item.price * order_item.quantity
        order_item.style = ps[1] if ps.length>1
        if order_item.post
          order_item.postage_total = (order_item.quantity / order_item.postage_unit) * order_item.postage
          order_item.postage_total = order_item.postage if order_item.quantity < order_item.postage_unit
        end
        order_items << order_item
      else
        self.remove k        #商品不存在时，从购物车中删除
      end
    end
    return order_items
  end
  
  def keys
    self.data.keys
  end
  
  #将购物车转换为订单
  def create_order
    order = Store::Order.new(:user_id=>self._id,:status=>Store::Order::STATUS_INIT)
    items = self.order_items
    items.each do |item|
      product = Store::Product.find(item.product_id)
      raise "#{product.name} 只有#{product.quantity}#{product.unit}" if product.quantity<item.quantity
      item.postage_total = 0 #不计算邮费
      order.total = order.total + item.subtotal+item.postage_total
      order.post = true if product.post
      item.order = order
      item.save
    end
     order.save
    return order
  end
end
