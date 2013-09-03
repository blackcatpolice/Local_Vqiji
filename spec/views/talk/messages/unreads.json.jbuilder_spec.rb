require 'spec_helper'

describe 'talk/messages/unreads.json.jbuilder' do
  let(:feed) { create :talk_feed }
  let(:user) { create :user }
  
  before(:each) do
    view.stub(:current_user).and_return(user)
  end
  
  before :each do
    assign(:feeds, [feed])
    
    render
    @json = JSON.parse(rendered)
  end
  
  it 'should render an Array' do
    @json.should be_kind_of(Array)
  end
  
  it 'should render 1 items' do
    @json.should have(1).items
  end
  
  describe 'message' do
    let(:jmessage) { @json[0] }
    
    it 'should render id' do
      jmessage['id'].should == feed.to_param
    end
    
    it 'should render html' do
      assert jmessage.key? 'html'
    end
  end
end
