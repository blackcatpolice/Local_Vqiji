require 'spec_helper'

describe 'talk/sessions/pull.json.jbuilder' do
  let(:feed) { create :talk_feed }
  
  before :each do
    @sessions = [feed.session]
    assign(:sessions, @sessions)
    render
    @json = JSON.parse(rendered)
  end
  
  it 'should render an Hash' do
    @json.should be_kind_of(Hash)
  end
  
  it 'should have session' do
    @json[feed.session.id.to_s].should_not be_nil
  end
  
  describe 'session' do
    before :each do
      @session = @json[feed.session.id.to_s]
    end
    
    it 'should render unread_count' do
      assert @session.key? 'unread_count'
    end
    
    it 'unread_count should be 1' do
      @session['unread_count'].should == 1    
    end
    
    it 'should render messages' do
      assert @session.key? 'messages'
    end
    
    it 'messages should be an array' do
      @session['messages'].should be_kind_of(Array) 
    end
    
    describe 'message' do
      before :each do
        @message = @session['messages'][0]
      end
  
      it 'should render id' do
        assert @message.key?('id')
      end
      
      it 'should render sender' do
        assert @message.key? 'sender'
      end
      
      describe 'sender' do
        before :each do
          @sender = @message['sender']
        end
        it 'should render id' do
          assert @sender.key?('id')
        end
        
        it 'should render name' do
          assert @sender.key?('name')
        end
      end
      
      it 'should render created_at' do
        assert @message.key? 'created_at'
      end
      
      it 'should render rtext' do
        assert @message.key? 'rtext'
      end
    end
  end
end
