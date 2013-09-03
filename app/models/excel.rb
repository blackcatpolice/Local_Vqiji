# encoding: utf-8

class Excel
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  mount_uploader :file, FileUploader, mount_on: :filename
  field :remark,      :type => String
  field :imported_at, :type => DateTime  # 导入时间
  field :import_errors, :type => Array # 导入错误信息
  belongs_to :uploader, class_name: 'User', inverse_of: nil # 上传人
  
  validates_presence_of :file
  
  def imported?
    !!imported_at
  end

  def import!
    raise ImportError, '文件已经被导入，不可以重复操作' if imported?
    
    attribute_setters = {
      '姓名' => ->(user, name) { user.name = name },
      '员工号' => ->(user, job_no) { user.job_no = job_no },
      '性别' => ->(user, gender) { user.gender = ( gender == '女' ? User::GENDER_FEMALE : User::GENDER_MALE ) },
      '职位' => ->(user, job) { user.job = job },
      '手机号码' => ->(user, phone) {
        # FIXED: '13800000000.0' => 13800000000
        user.phone = ( '%d' % phone)
      },
      '身份证号码' => ->(user, id_number) { user.id_number = id_number },
      '顶级部门' => ->(user, top_department) {
        unless top_department.blank?
          user.department = Department.find_or_create_by(:name => top_department, :level => Department::TOP_LEVEL)
        end
      },
      '一级部门' => ->(user, first_department) {
        unless first_department.blank?
          user.department = ((user.department && user.department.subs) || Department)
            .find_or_create_by(:name => first_department, :level => Department::FIRST_LEVEL)
        end
      },
      '二级部门' => ->(user, second_department) {
        unless second_department.blank?
          if user.department && (user.department.level == Department::FIRST_LEVEL)
            user.department = user.department.subs
              .find_or_create_by(:name => second_department, :level => Department::SECOND_LEVEL)
          end
        end
      },
      '电子邮箱' => ->(user, email) { user.email = email },
      '密码' => ->(user, password) { user.password = password },
      '出生日期' => ->(user, birthday) { user.birthday = Time.parse(birthday).to_date }
    }

    errors = []
    # require 'spreadsheet'
    Spreadsheet.client_encoding = "UTF-8" 
    book = Spreadsheet.open( file.path )
    sheet = book.worksheet 0
    
    sheet.each do |row|
      next if row.idx == 0 # 跳过标题行（第一行）
      
      # 单独设置 department
      department = nil
      
      user = User.new do |user|
        row.each_with_index do |value, index|
          setter = attribute_setters[ sheet.cell(0, index) ]
          setter.call(user, value) if setter
        end
        
        department = user.department
        user.department = nil
        # 设置默认参数
        user.password = '12345678' if (user.password == nil) # 默认密码
      end
      
      if user.save
        department.add_member(user)
      else
        error = ("create user error from row(%d): %s" % [row.idx, user.errors.full_messages.join(',')])
        errors << error
      end
    end

    self.import_errors = errors if errors.any?
    self.imported_at = Time.now
    self.save!
  end
  
  class ImportError < RuntimeError; end
end

