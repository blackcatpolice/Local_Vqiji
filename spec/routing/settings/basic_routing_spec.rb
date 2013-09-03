require 'spec_helper'

describe Settings::BasicController do
  describe "routing" do
    it "shoud route / to #show" do
      get("/settings/basic").should route_to("settings/basic#show")
    end
  end
end
