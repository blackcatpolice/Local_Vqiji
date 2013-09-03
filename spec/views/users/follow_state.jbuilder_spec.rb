require 'spec_helper'

describe 'users/follow_state.json.jbuilder' do
  let(:user) { create :user }
  let(:other) { create :user }
  
  before(:each) do
    view.stub(:current_user).and_return(user)
    @user = create :user
    
    render
    
    @json = JSON.parse(rendered)
  end
  
  [ :id, :followed, :is_fan ].each do |key|
    it "should render #{key}" do
      assert @json.key?(key.to_s)
    end
  end
end
