# encoding: utf-8

# t.string :employee_no,   null: false, limit: 32 #员工号
# t.string :name,   null: false, limit: 64 #员工姓名
# t.string :id_number,   null: false, limit: 32 #身份证号
# t.integer :gender, null: false, default: 1 #性别
# t.integer :company_id, null: false #公司ID
# t.integer :department_id,null: false #部门编号
# t.boolean :is_leader,null: false, default: false #是否为部门领导
# t.string :group_ids #所属组ID，临时属性
# t.boolean :enable,null: false, default: true #是否启用
#员工模型

class Employee
  include Mongoid::Document
  field :name, type: String # 名称
  field :id_number,type: String #身份证号
  field :gender ,type: Integer # 性别
  field :is_leader,type: Boolean , default: false #是否为leader
  field :enable,type: Boolean,default: true # 是否启用
  field :group_ids,type:String
   
   #attr_accessible :id,:name,:gender
   #belongs_to :company, class_name: 'Company' #所在公司
   belongs_to :department,class_name: 'Department' # 所在部门
   
   #belongs_to :department, class_name: 'Work::Group' #员工所在部门
   
   
   def user
      return User.find_by_employee_no self.employee_no
   end
   
  
   
   #根据员工进行注册
   def self.register user
    raise "没有用户信息" if user.nil?
    #
    unless Employee.exists? :employee_no => user.employee_no, :name=>user.real_name,:id_number=>user.id_number
      raise "认证失败工号 姓名  身份证不一致"
    end
    employee = Employee.find_by_employee_no user.employee_no
    raise "员工号已经注册" if User.exists? :employee_no=>user.employee_no
    raise "邮箱已经被使用" if User.exists? :email=>user.email
    #raise "昵称已经被使用" if User.exists? :nickname=>user.nickname
    raise "数据验证未通过" unless user.valid?
    #
    user.jifen = 10000 #测试期间，默认加入1万积分
    user.company_id = employee.company_id
    user.department_id = employee.department_id
    
    #asset_path('defaults/wkusers/' + ['avatar.png'].compact.join('_'))
    #
    if user.save
      #添加用户到工作组
      group_ids = employee.group_ids.split(",")
      group_ids.each do |gid|
        group = Work::Group.find(gid.to_i)
         if group
          Work::Member.new(:user=>user,:group=>group,:isadmin=>employee.is_leader).save
         end
      end
    end
   end
   
end
