require 'spec_helper'

describe Widgets::WeatherController do
  describe "routing" do
    it "should routes to #t" do
      get("/widgets/weather/t").should route_to("widgets/weather#t")
    end
  end
end
