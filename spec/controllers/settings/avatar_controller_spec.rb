require 'spec_helper'

describe Settings::AvatarController do
  let(:current_user) { create(:user) }
  
  before(:each) do
    sign_in current_user
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "POST 'octet_stream_update'" do
    it "returns http success" do
      #post 'octet_stream_update'
      #response.should be_success
      pending 'FIXME!'
    end
  end
end
