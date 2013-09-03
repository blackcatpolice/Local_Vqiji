# encoding: utf-8
require 'spec_helper'

describe 'talk/sessions/fetch.json.jbuilder' do
  let(:session) { create :talk_session }
  
  before(:each) do
    assign(:sessions, [session])
    
    view.stub(:current_user).and_return(session.user)
    view.stub(:talk_session_title).and_return('title')
    view.stub(:talk_session_subtitle).and_return('subtitle')
    view.stub(:talk_session_avatar_url).and_return('avatar_url')
    
    render
    @jsessions = JSON.parse(rendered)
  end
  
  it 'should be an Hash' do
    @jsessions.should be_kind_of(Hash)
  end
  
  it 'should render current session id' do
    assert @jsessions.key?('current')
  end
  
  it 'should render sessions' do
    @jsessions['sessions'].should be_kind_of(Array)
    @jsessions['sessions'].should have(1).items
  end
  
  describe 'session in sessions' do
    let(:jsession) { @jsessions['sessions'][0] }
    
    it 'should render id' do
      jsession['id'].should == session.to_param
    end
    
    it 'should render group_id' do
      jsession['group_id'].should == session.group_id.to_s
    end
    
    it 'should render p2p' do
      jsession['p2p'].should == false
    end
    
    it 'should render unread_count' do
      jsession['members_count'].should == session.group.sessions_count
    end
    
    it 'should render members_count' do
      jsession.key? 'members_count'
    end
    
    it 'should render title' do
      jsession['title'].should == 'title'
    end
    
    it 'should render subtitle' do
      jsession['subtitle'].should == 'subtitle'
    end
    
    it 'should render avatar_url' do
      jsession['avatar_url'].should == 'avatar_url'
    end
  end
end


