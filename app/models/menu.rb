## encoding: utf-8
##
##
##后台管理菜单
class Menu
  include Mongoid::Document
  include Mongoid::Timestamps
  ##
  scope :root_scope,lambda{where(:parent => '')}
  scope :head_scope,lambda{|pid|child_scope(pid).where(:url => '')}
  scope :child_scope,lambda{|url|where(:parent => url)}
  #scope :many_scope,lambda{|ids|where(:id_in=>ids)}
  ##
  ##
  field :name,type:String   # 权限名
  field :url,type:String    # URL 为空表示二级菜单
  field :parent,type:String # 上一级 为空表示一级菜单
  field :remark,type:String # 菜单备注
  field :priority,type:String #优先级
  
  #key :url
  
  def children
    Menu.child_scope(self.url)
  end
  
  #得到所有菜单URL
  def self.get_all_urls
    menus = Menu.only(:url)
    menu_ids = Array.new
    menus.each do |menu|
      menu_ids << menu.url
    end
    return menu_ids
  end

  #load all menus  
  def self.load
    Menu.destroy_all
    #
    Menu.create(:name=>"商城",:parent=>'',:url=>"/admin/store",:remark=>"商城管理")
    Menu.create(:name=>"问问",:parent=>'',:url=>"/admin/wenwen",:remark=>"问答管理")
    Menu.create(:name=>"微博",:parent=>'',:url=>"/admin/weibo",:remark=>"微博管理")
    Menu.create(:name=>"专题",:parent=>'',:url=>"/admin/blog",:remark=>"专题管理")
    Menu.create(:name=>"系统管理",:parent=>'',:url=>"/admin/system",:remark=>"系统管理")
    
    ##
    Menu.create(:name=>"订单管理",:parent=>"/admin/store",:url=>'#orders',:remark=>"")
    Menu.create(:name=>"商品管理",:parent=>"/admin/store",:url=>'#products',:remark=>"")
    Menu.create(:name=>"发票报销",:parent=>"/admin/store",:url=>'#invoices',:remark=>"")
   
    ##qa开始
    Menu.create(:name=>"问题管理",:parent=>"/admin/wenwen",:url=>'#qas',:remark=>"")
    Menu.create(:name=>"专家管理",:parent=>"/admin/wenwen",:url=>'#doctors',:remark=>"")
    
    Menu.create(:name=>"新建公开问题",:parent=>"#qas",:url=>"/admin/questions/new",:remark=>"")
    Menu.create(:name=>"用户问题列表",:parent=>"#qas",:url=>"/admin/questions/private",:remark=>"")
    Menu.create(:name=>"公开问题列表",:parent=>"#qas",:url=>"/admin/questions/public",:remark=>"")
    
    Menu.create(:name=>"新建专家",:parent=>"#doctors",:url=>"/admin/doctor/new",:remark=>"")
    Menu.create(:name=>"专家列表",:parent=>"#doctors",:url=>"/admin/doctor",:remark=>"")
   ##qa结束 
   
   #专题开始
    Menu.create(:name=>"专题管理",:parent=>"/admin/blog",:url=>'#subs',:remark=>"")
    Menu.create(:name=>"导航管理",:parent=>"/admin/blog",:url=>'#navs',:remark=>"")
    
    Menu.create(:name=>"新建专题",:parent=>"#subs",:url=>"/admin/subjects/new",:remark=>"")
    Menu.create(:name=>"专题列表",:parent=>"#subs",:url=>"/admin/subjects",:remark=>"")
    
    Menu.create(:name=>"新建导航",:parent=>"#navs",:url=>"/admin/blognavs/new",:remark=>"")
    Menu.create(:name=>"导航列表",:parent=>"#navs",:url=>"/admin/blognavs",:remark=>"")
   
   #专题结束
    
    Menu.create(:name=>"权限管理",:parent=>"/admin/system",:url=>"#auth",:remark=>"")
    #
    Menu.create(:name=>"订单列表",:parent=>"#orders",:url=>"/admin/orders",:remark=>"")
    Menu.create(:name=>"商品列表",:parent=>"#products",:url=>"/admin/products",:remark=>"")
    Menu.create(:name=>"商品类型列表",:parent=>"#products",:url=>"/admin/product_types",:remark=>"")
    Menu.create(:name=>"报销列表",:parent=>"#invoices",:url=>"/admin/invoices",:remark=>"")
    Menu.create(:name=>"网站审批列表",:parent=>"#invoices",:url=>"/admin/invoices/website",:remark=>"")
    Menu.create(:name=>"部门审批列表",:parent=>"#invoices",:url=>"/admin/invoices/dept",:remark=>"")
    Menu.create(:name=>"人事审批列表",:parent=>"#invoices",:url=>"/admin/invoices/hr",:remark=>"")
    Menu.create(:name=>"角色列表",:parent=>"#auth",:url=>"/admin/roles",:remark=>"")
    Menu.create(:name=>"用户列表",:parent=>"#auth",:url=>"/admin/users",:remark=>"")
    Menu.create(:name=>"管理员列表",:parent=>"#auth",:url=>"/admin/admins",:remark=>"")

  end
  
  def self.load_store
    
  end
  
  def self.load_qa
    
  end
  
  def self.load_system
    
  end
  
end
