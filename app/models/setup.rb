## encoding: utf-8
##权限类，用于定义一些权限相关的方法
class Setup
  require 'spreadsheet'
  
  USER_TAGS = ["甜美","有责任心","幽默","乖巧","如花似玉","拉风","忧郁","孤僻","小清新","坚强"]
  
  def self.load_excel
    #
    path_file = "#{Rails.root}/db/seeds/data.xls"
    book = Spreadsheet.open path_file
    #加载公司数据
    p '加载公司数据....'
    company_sheet = book.worksheet 0
    company_sheet.each do |row|
      if(row && row.idx>0 && row[1])
       Company.create!(:id=>row[0],:name=>row[1])
      end
    end
    p '加载部门/工作组数据....'
    #加载部门/工作组数据
    group_sheet = book.worksheet 1
    group_sheet.each do |row|
      if(row && row.idx>0 && row[1] && row[2])
        company = Company.find(row[2].to_i)
        Work::Group.create!(:id=>row[0],:name=>row[1],:company_id=>row[2])
        #Department.create!(:id=>row[0],:name=>row[1],:company_id=>row[2])
      end
    end
    p '加载员工数据....'
    #加载员工数据
    employee_sheet = book.worksheet 2
    employee_sheet.each do |row|
      department = (Department.get_by_name row[5])
      if(row && row.idx>0 && row[0] && department)
        emp = Employee.new(
            :name=> row[0],:company_id=>row[1],:employee_no=>row[2],:gender=>row[3],:group_ids=>row[4],
            :department_id=>department.id,:is_leader=>row[6]||0,:id_number=>row[7])
        emp.save! 
      end     
    end
  end
  
end
