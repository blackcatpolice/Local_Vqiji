require 'spec_helper'

describe 'devise/sessions/new.html.erb' do
  let(:user) { create :user }
  
  before {
    view.stub(:resource_name) { :user }
    view.stub(:resource) { user }
    view.stub(:devise_mapping) { @devise_mapping ||= Devise.mappings[:user] }
    render
  }

  it 'should include form-signin' do
    assert_select('form.form-signin') do
      assert_select('input[name=?]', 'user[login]')
      assert_select('input[name=?]', 'user[password]')
      assert_select('input[name=?]', 'user[remember_me]')
      assert_select('input[type=?]', 'submit')
    end
  end
end
