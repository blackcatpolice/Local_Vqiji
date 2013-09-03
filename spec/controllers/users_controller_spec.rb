require 'spec_helper'

describe UsersController do
  let(:current_user) { create :user }
  before(:each) { sign_in current_user }

  describe "GET 'card'" do
    let(:other) { create :user }
  
    it "returns http success" do
      get 'card', :id => other.to_param, format: :json
      response.should be_success
    end

    it "should assign @user" do
      get 'card', :id => other.to_param, format: :json
      assigns[:user].should == other
    end
  end
end
