require 'spec_helper'

describe 'talk/messages/new_modal_to_user.html.erb' do
  before :all do
    @receiver = create :user, name: 'new_modal_to_user-receiver'
  end
  
  it 'should render user name' do
    render
    rendered.should have_text('new_modal_to_user-receiver')
  end
end
