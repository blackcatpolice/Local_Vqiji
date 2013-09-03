require 'spec_helper'

describe Talk::MembersController do
  before(:each) do
    @talk_group = create :talk_group
    @user = @talk_group.creater
    @talk_session = @talk_group.session_for(@user)
  end
  
  before(:each) { sign_in @user }

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', session_id: @talk_session.to_param
      response.should be_success
    end
    
    it 'should assign all members into @members' do
      get 'index', session_id: @talk_session.to_param
      assigns[:members].should == [@talk_session]
    end
    
    it 'should render "index"'do
      get 'index', session_id: @talk_session.to_param
      response.should render_template('index')
    end
    
    describe 'with format: "json"' do
      it 'should render "index"'do
        get 'index', session_id: @talk_session.to_param, format: :json
        response.should render_template('index')
      end
    end
  end
  
  describe "POST 'add'" do
    before :each do
      @users = create_list(:user, 3)
      @user_ids = @users.collect(&:id)

      post 'add', {
        session_id: @talk_session.to_param,
        members: @user_ids,
        format: :json
      }
    end
  
    it "returns http success" do
      response.should be_success
    end
    
    it "should add users" do
      @talk_session.group.sessions.includes(:user).collect(&:user).should include(*@users)
    end
  end
  
  describe "DELETE 'destroy'" do
    before :each do
      @u2 = create :user
      @member = @talk_group.add_member(@u2)
      
      delete 'destroy', {
        session_id: @talk_session.to_param,
        id: @u2.to_param,
        format: :json
      }
    end
  
    it "returns http success" do
      response.should be_success
    end
    
    it 'should render true' do
      response.body.should == 'true'
    end
  end
end
