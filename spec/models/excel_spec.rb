require 'spec_helper'

describe ::Excel do
  it '#import!' do
    DatabaseCleaner.clean
    
    begin
      file = File.open( File.expand_path('../../assets/人力资源部人员信息.xls', __FILE__) )
      excel = Excel.create!(:file => file)
    ensure
      file.close if file
    end

    User.count.should == 0
    Department.count.should == 0

    excel.import!

    User.count.should == 2
    Department.count.should == 4
    
    # user (1陈一)
    user0 = User.asc(:name).first
    user0.name.should == '1陈一'
    user0.job_no.should == '00001'
    user0.job.should == '党支部书记'
    user0.gender.should == User::GENDER_MALE
    user0.phone.should == '13800000000'
    user0.id_number.should == '210300197500170010'
    
    user0.department.name.should == '招聘组'
    user0.department.level.should == Department::SECOND_LEVEL
    user0.department.sup.name.should == '人力资源部'
    user0.department.sup.level.should == Department::FIRST_LEVEL

    # user (2蔡二)
    user1 = User.asc(:name)[1]
    user1.name.should == '2蔡二'
    user1.job_no.should == '00002'
    user1.job.should == '副总经理'
    user1.gender.should == User::GENDER_FEMALE
    user1.phone.should == '13900000000'
    user1.id_number.should == '410608637602090331'
    
    user1.department.name.should == '信息技术部'
    user1.department.level.should == Department::FIRST_LEVEL
    user1.department.sup.name.should == '开发部'
    user1.department.sup.level.should == Department::TOP_LEVEL
    
    excel.imported_at.should_not be_nil
    excel.imported?.should be_true
  end
end
