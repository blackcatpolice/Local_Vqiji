require 'spec_helper'

describe Settings::PasswordController do
  describe "routing" do
    it "should routes to #edit" do
      get("/settings/password/edit").should route_to("settings/password#edit")
    end
    
    it "shoud route / to #edit" do
      get("/settings/password").should route_to("settings/password#edit")
    end
    
    it "should routes to #update" do
      put("/settings/password").should route_to("settings/password#update")
    end
  end
end
