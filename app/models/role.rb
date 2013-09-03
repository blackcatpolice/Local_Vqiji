# encoding: utf-8
#
#
# 用户组
class Role
  include Mongoid::Document
  include Mongoid::Timestamps
  #
  # has_and_belongs_to_many :menus
  #
  
  field :name, type:String ## 角色名
  field :remark, type:String ## 角色备注
  field :menu_ids, type:Array ## 角色对应的菜单ID
  #
  # key :name
  
  #
  def self.get id
    begin
      return find(id)
    rescue Mongoid::Errors::DocumentNotFound #
      return nil
    end
  end
  
  def menu_id_hash
    return @menu_id_hash if @menu_id_hash
    @menu_id_hash = Hash.new
    if self.menu_ids
    self.menu_ids.each do |mid|
      @menu_id_hash[mid] = 1
    end
    end
    return @menu_id_hash
  end
  
  # 创建角色
  def self.create_! options
    role = Role.new(options)
    role.save!
  end
  
  #
  def top_menu
   tops = Menu.root_scope.any_in(:_id=>self.menu_ids)
   return tops
  end
  
  
  def head_menu pid
    menus = Menu.child_scope(pid).any_in(:_id=>self.menu_ids)
    return menus
  end
  
  def menu pid
    menus = Menu.child_scope(pid).any_in(:_id=>self.menu_ids)
    return menus
  end
  
  def temp 
    tops = Menu.root_scope.any_in(:_id=>self.menu_ids)
    ts = Array.new 
    tops.each do |t|
      #t.name = "tt"
      heads = self.head_menu t.id
      t.heads = Array.new
      heads.each do |h|
        t.heads << h
        menus = self.menu h.id
        h.menus = Array.new
        menus.each do |m| 
          h.menus << m
        end
      end
      ts << t
    end
    return ts
  end
end
