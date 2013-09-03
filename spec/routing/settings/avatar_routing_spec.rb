require 'spec_helper'

describe Settings::AvatarController do
  describe "routing" do
    it "should routes to #edit" do
      get("/settings/avatar/edit").should route_to("settings/avatar#edit")
    end
    
    it "shoud route / to #edit" do
      get("/settings/avatar").should route_to("settings/avatar#edit")
    end
    
    it "should routes to #octet_stream_update" do
      post("/settings/avatar").should route_to("settings/avatar#octet_stream_update")
    end
  end
end
