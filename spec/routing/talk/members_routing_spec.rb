# encoding: utf-8

require 'spec_helper'

describe Talk::MembersController do
  describe "routing" do
    it "should routes to #index" do
      get("/talk/sessions/1/members").should route_to("talk/members#index", session_id: "1")
    end
    
    it "should routes to #add" do
      post("/talk/sessions/1/members/add").should route_to("talk/members#add", session_id: "1")
    end
    
    it "should routes to #destroy" do
      delete("/talk/sessions/1/members/1").should route_to("talk/members#destroy", session_id: "1", id: "1")
    end
  end
end
