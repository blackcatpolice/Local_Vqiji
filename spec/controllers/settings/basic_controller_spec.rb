require 'spec_helper'

describe Settings::BasicController do
  let(:current_user) { create(:user, gender: 0, birthday: 18.years.ago, from: create(:city_in_china)) }
  
  before(:each) do
    sign_in current_user
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end
end
