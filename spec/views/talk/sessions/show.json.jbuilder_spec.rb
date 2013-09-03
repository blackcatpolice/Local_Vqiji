# encoding: utf-8
require 'spec_helper'

describe 'talk/sessions/show.json.jbuilder' do
  let(:session) { create :talk_session }
  
  before(:each) do
    assign(:session, session)
    
    view.stub(:current_user).and_return(session.user)
    view.should_receive(:talk_session_title).once.and_return('title')
    view.should_receive(:talk_session_subtitle).once.and_return('subtitle')
    view.should_receive(:talk_session_avatar_url).once.and_return('avatar_url')

    render
    @jsession = JSON.parse(rendered)
  end
  
  it 'should be an Hash' do
    @jsession.should be_kind_of(Hash)
  end
 
  it 'should render id' do
    @jsession['id'].should == session.to_param
  end
  
  it 'should render group_id' do
    @jsession['group_id'] == session.group_id.to_s
  end
    
  it 'should render p2p' do
    @jsession['p2p'].should == false
  end
  
  it 'should render unread_count' do
    @jsession['unread_count'].should == session.unread_count
  end
  
  it 'should render title' do
    @jsession['title'].should == 'title'
  end
  
  it 'should render subtitle' do
    @jsession['subtitle'].should == 'subtitle'
  end

  it 'should render members_count' do
    @jsession['members_count'].should == session.group.sessions_count
  end
  
  it 'should render avatar_url' do
    @jsession['avatar_url'].should == 'avatar_url'
  end
end


