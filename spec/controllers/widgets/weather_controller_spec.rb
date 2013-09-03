require 'spec_helper'

describe Widgets::WeatherController do
  before :each do
    create :widget_weather_scope, :name => '重庆', :code => 'Chongqing, CN'
  end

  describe "GET 't'" do
    it "returns http success" do
      get 't', { search: '重庆' }
      response.should be_success
      response.body.should == { search: "重庆", code: "Chongqing, CN" }.to_json
    end
  end
end
