# encoding: utf-8
class Courier
  include Mongoid::Document
  field :name, type: String #快递名
  field :telephone,type: String #联系电话
  field :url,type: String #快递链接
  field :remark,type: String #快递备注
  
end