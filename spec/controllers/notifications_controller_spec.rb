require 'spec_helper'

describe NotificationsController do
  let(:current_user) { create :user }
  before(:each) { sign_in current_user }

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'nb'" do
    it "returns http success" do
      get 'nb'
      response.should be_success
    end
    
    it "should assign @map" do
      get 'nb'
      assigns[:map].should_not be_nil
    end
  end
  
  describe "GET 'count'" do
    it "returns http success" do
      get 'count'
      response.should be_success
    end
  end
end
