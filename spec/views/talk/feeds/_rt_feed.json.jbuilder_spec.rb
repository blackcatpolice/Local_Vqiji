require 'spec_helper'

describe 'talk/feeds/_rt_feed.json.jbuilder' do
  let(:user) { create :user }
  let(:feed) { create :talk_feed }
  
  before(:each) do
    view.stub(:current_user).and_return(user)
  end
  
  before :each do
    view.stub(:feed).and_return(feed)
    render
    
    @json_feed = JSON.parse(rendered)
  end
  
  it 'should render id' do
    assert @json_feed.key?('id')
  end

  it 'should render html' do
    assert @json_feed.key? 'html'
  end
end
