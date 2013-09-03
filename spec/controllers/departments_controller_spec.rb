require 'spec_helper'

describe DepartmentsController do
  render_views
  
  let(:user) { create :user }
  before(:each) { sign_in user }
  
  def _should_be_same_department(department, department_json)
    department.id.to_s.should == department_json['id']
    department.name.should == department_json['name']
  end
  
  it "#index.json" do
    _department = create :second_level_department, members_count: 0
    
    get 'index', format: :json
    response.should be_success
    
    _departments = JSON.parse(response.body)
    _should_be_same_department(_department.sup.sup, _departments[0])
    _should_be_same_department(_department.sup, _departments[0]['subs'][0])
    _should_be_same_department(_department, _departments[0]['subs'][0]['subs'][0])
  end

  describe "GET 'flat'" do
    it "returns http success" do
      get 'flat', format: :json
      response.should be_success
    end
    
    it "should assign @departments" do
      get 'flat', format: :json
      assigns[:departments].should_not be_nil
    end
  end
  
  it "#members.json" do
    _department = create :department
    get 'members', id: _department.id , format: :json
    
    response.should be_success
    assigns(:department).should == _department

    _members = JSON.parse(response.body)
    _members.should have(_department.members.count).items
    _members.all? {|m| m.key?('id') and m.key?('name')  }.should be_true
  end

end
