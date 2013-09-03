require 'spec_helper'

describe Talk::SessionsController do
  let(:session) { create :talk_session }
  let(:group) { talk_session.group }
  let(:user) { session.user }
  
  before(:each) { sign_in user }

  it "#index" do
    get 'index'
    response.should be_success
    assigns(:sessions).should have(1).items
    assigns(:sessions).should include(session)
  end
  
  it "#create" do
    _member_ids = create_list(:user, 3).collect(&:id)
    post 'create', topic: 'Topic', members: _member_ids, format: :json
    
    response.should be_success
    assigns(:session).should be_an_instance_of(Talk::Session)
    assigns(:session).group.creater.should == user
    assigns(:session).group.topic.should == 'Topic'
    assigns(:session).group.should have(4).sessions
  end

  describe 'GET "show"' do
    before :each do
      get 'show', id: session.id
    end
    
    it 'should response http success' do
      response.should be_success
    end
    
    it 'should assign @session' do
      assigns(:session).should == session      
    end
  end

  it "#destroy" do
    Talk::Service.any_instance.should_receive(:quit!).with(session.group).once
    delete 'destroy', id: session.id, format: 'json'
    response.should be_success
    assigns(:session).should == session
  end

  describe "#pull" do
    it 'should response http success' do
      get 'pull', format: 'json'
      response.should be_success
    end
    
    it 'should assigns @sessions' do
      get 'pull', format: 'json'
      assigns[:sessions].should_not be_nil
    end
    
    it 'should render template "talk/sessions/pull"' do
      get 'pull', format: 'json'
      response.should render_template('talk/sessions/pull')
    end
  end

  describe "#fetch" do
    it 'should response http success' do
      get 'fetch', format: 'json'
      response.should be_success
    end
    
    it 'should assigns @sessions' do
      get 'fetch', format: 'json'
      assigns[:sessions].should == [session]
    end
    
    it 'should assigns @realtime_current_session' do
      get 'fetch', format: 'json'
      assigns[:current_session].should == Talk::Realtime.current_session(user)
    end
    
    it 'should render template "talk/sessions/fetch"' do
      get 'fetch', format: 'json'
      response.should render_template('talk/sessions/fetch')
    end
  end
  
  describe "#make_current" do
    it 'should response http success' do
      get 'make_current', id: session.to_param, format: 'json'
      response.should be_success
      response.body.should == 'true'
    end
    
    it 'should call Talk::Realtime.set_current_session' do    
      Talk::Realtime.should_receive(:set_current_session).once.with(user, session)
      post 'make_current', id: session.to_param, format: :json
    end
  end

  describe "#clear_current" do
    it 'should response http success' do
      get 'clear_current', format: 'json'
      response.should be_success
      response.body.should == 'true'
    end
    
    it 'should call Talk::Realtime.clear_current_session' do
      Talk::Realtime.should_receive(:clear_current_session).once.with(user)
      post 'clear_current', format: :json
    end    
  end
end
