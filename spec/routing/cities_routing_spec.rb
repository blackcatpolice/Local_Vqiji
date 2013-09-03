require 'spec_helper'

describe CitiesController do
  describe "routing" do
    it "should routes to #index" do
      get("/cities").should route_to("cities#index")
    end
  end
end
