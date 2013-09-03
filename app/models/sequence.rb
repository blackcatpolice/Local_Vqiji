# suxu
#序列号
class Sequence
  ##
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  ##
  TYPE_ORDER = "order"
  TYPE_PRODUCT = "product"
  TYPE_INVOICE = "invoice"
  ##
  belongs_to :user,class_name:'Usercpy'
  field :type,type:String # 序列类型
  field :value,type:String #序列值
  
  #得到商品序列
  def self.product
    max_no = Sequence.where(:type=>TYPE_PRODUCT).max("value")
    num = 10001
    num = max_no.to_i+1 if !max_no.nil? && max_no!=0
    sequence = Sequence.new(:type=>TYPE_PRODUCT,:value=>"#{num}")
    sequence.save
    return sequence.value
  end
  
  #得到订单序列
  def self.order
    ymd = Time.now.strftime("%Y%m%d")
    max_no = Sequence.where(:type=>TYPE_ORDER).max("value")
    num = 1001
    num = max_no[8,max_no.length].to_i+1 if !max_no.nil? && max_no[0,8] == ymd
    sequence = Sequence.new(:type=>TYPE_ORDER,:value=>"#{ymd}#{num}")
    sequence.save
    return sequence.value
  end
  
  #得到发票序列
  def self.invoice
    ymd = Time.now.strftime("%Y%m%d")
    max_no = Sequence.where(:type=>TYPE_INVOICE).max("value")
    num = 1001
    num = max_no[8,max_no.length].to_i+1 if max_no && max_no[0,8] == ymd
    sequence = Sequence.new(:type=>TYPE_INVOICE,:value=>"#{ymd}#{num}")
    sequence.save
    return sequence.value
  end

end
