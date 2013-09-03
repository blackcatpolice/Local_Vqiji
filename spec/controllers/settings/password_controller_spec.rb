require 'spec_helper'

describe Settings::PasswordController do

  let(:current_user) { create :user, password: '12345678' }

  before :each do
    sign_in :user, current_user
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "POST 'update'" do
    it "returns http success" do
      post 'update', user: { current_password: '12345678', password: '123456789', password_confirmation: '123456789' }
      response.should be_success
      assigns(:current_user).should == current_user
      assigns(:current_user).valid_password?('123456789').should be_true
    end
  end

end
