require 'spec_helper'

describe Talk::MessagesController do
  let(:session) { create :talk_session }
  let(:group) { session.group }
  let(:current_user) { session.user }

  before(:each) { sign_in current_user }
  
  it "#index" do
    get 'index', session_id: session.id, format: 'json'
    response.should be_success
  end

  it "#create" do
    post 'create', session_id: session.id, text: 'How do you do!', format: 'json'
    
    response.should be_success
    assigns(:feed).should be_an_instance_of(Talk::Feed)
  end

  it "#show" do
    talk_feed = create :talk_feed, receiver: current_user
    get 'show', id: talk_feed.id, format: 'json'
    
    response.should be_success
    assigns(:feed).should == talk_feed
  end
  
  it "#destroy" do
    talk_feed = create :talk_feed, receiver: current_user
    delete 'destroy', id: talk_feed.id, format: 'json'
    
    response.should be_success
    assigns(:feed).deleted?.should be_true
  end

  describe "#rt_create" do
    before :each do
      post 'rt_create', session_id: session.id, text: 'How do you do!', format: 'json'
    end
    
    it "should response http success" do
      response.should be_success
    end
    
    it "should create feed" do
      assigns(:feed).should be_an_instance_of(Talk::Feed)
    end
    
    it "should render talk/feeds/_feed2" do
      response.should render_template('talk/feeds/_rt_feed')
    end
  end
  
  describe "#unreads" do
    before :each do
      get 'unreads', session_id: session.id, format: 'json'
    end
    
    it "should response http success" do
      response.should be_success
    end
    
    it "should assign @feeds" do
      assigns(:feeds).should_not be_nil
    end
    
    it "should set response.headers['response-at']" do
      response.headers['response-at'].should_not be_nil
    end
    
    it "should render talk/unreads" do
      response.should render_template('talk/messages/unreads')
    end
  end
  
  describe "#unread_count" do
    before :each do
      get 'unread_count', session_id: session.id, format: 'json'
    end
    
    it "should response http success" do
      response.should be_success
    end
  end

  describe "#reset_unread_count" do
    it "should response http success" do
      post 'reset_unread_count', session_id: session.id
      response.should be_success
      response.body.should == 'true'
    end
    
    it "should call #reset_unread_count once" do
      Talk::Session.any_instance.should_receive(:reset_unread_count!).once
      post 'reset_unread_count', session_id: session.id
    end
    
    it 'should assign @session' do
      post 'reset_unread_count', session_id: session.id
      assigns[:session].should == session
    end
  end
  
  describe '#new_modal_to_user' do
    let(:receiver) { create :user }
  
    it 'should assign @receiver' do
      get 'new_modal_to_user', :user_id => receiver.to_param
      assigns[:receiver].should == receiver
    end
  
    it 'should render template talk/messages/new_modal_to_user' do
      get 'new_modal_to_user', :user_id => receiver.to_param
      response.should render_template('talk/messages/new_modal_to_user')
    end
    
    it 'should raise Talk::Error if receiver can\'t be find' do
      get('new_modal_to_user', :user_id => '1').should raise_error
    end
  end
  
  describe '#create_to_user' do
    let(:receiver) { create :user }
  end
end
