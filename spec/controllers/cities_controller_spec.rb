require 'spec_helper'

describe CitiesController do
  describe "GET 'index.json'" do
    it "returns http success" do
      get 'index', format: :json
      response.should be_success
    end
  end
end
