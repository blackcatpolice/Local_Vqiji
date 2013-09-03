#商品类型
class Store::ProductType
  include Mongoid::Document
  #scopes
  scope :base_scope,lambda{where(:parent => "")} #所有 parent = “” 时表示第一级商品类型
  
  
  #fields
  field :name, :type => String #类型名称
  field :parent, :type => String #上一级 如果等于 name 表示为第一级类型
  field :priority, :type => Integer #显示优先级
  field :enable,type:Boolean ,default:true #是否启用
  field :created_at ,type:Time, default:Time.now #创建时间
  
  #得到所有子类型
  def child_types
    return Store::ProductType.where(:parent=>self.name);
  end
  
  def child_types_str
    child_types = self.child_types
    str = ''
    child_types.each do |c|
      str =str+ c.name+" "
    end
    return str
  end
  
  #父类型
  def parent_type
    
  end
  
end
