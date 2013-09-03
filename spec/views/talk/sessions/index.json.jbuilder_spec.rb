require 'spec_helper'

describe 'talk/sessions/index.json.jbuilder' do

  before :each do
    @session = create(:talk_session)
    @session.stub(:unread_count).and_return(1)
    view.should_receive(:talk_session_title).once.and_return('title')
    view.should_receive(:talk_session_subtitle).once.and_return('subtitle')
    view.should_receive(:talk_session_avatar_url).once.and_return('avatar_url')
    assign(:sessions, [@session])
    render
    @jsessions = JSON.parse(rendered)
  end
  
  it 'should render an array' do
    @jsessions.should be_kind_of(Array)
  end
  
  it 'should have 1 item' do
    @jsessions.should have(1).items
  end
  
  describe 'session' do
    before :each do
      @jsession = @jsessions[0]
    end
    
    it 'should render id' do
      assert @jsession.key?('id')
      @jsession['id'].should == @session.id.to_s
    end
    
    it 'should render group_id' do
      assert @jsession.key?('group_id')
      @jsession['group_id'].should == @session.group_id.to_s
    end
    
    it 'should render p2p' do
      @jsession['p2p'].should == false
    end
    
    it 'should render unread_count' do
      assert @jsession.key?('unread_count')
      @jsession['unread_count'].should == 1
    end
    
    it 'should render title' do
      assert @jsession.key?('title')
      @jsession['title'].should == 'title'
    end
    
    it 'should render members_count' do
      @jsession['members_count'].should == @session.group.sessions_count
    end
    
    it 'should render subtitle' do
      @jsession['subtitle'].should == 'subtitle'
    end
    
    it 'should render avatar_url' do
      assert @jsession.key?('avatar_url')
      @jsession['avatar_url'].should == 'avatar_url'
    end
  end
end
