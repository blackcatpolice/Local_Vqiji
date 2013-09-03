# encoding: utf-8

require 'spec_helper'

describe Talk::SessionsController do
  describe "routing" do
    it "should routes to #index" do
      get("/talk/sessions").should route_to("talk/sessions#index")
    end
    
    it "should route /talk to #index" do
      get("/talk").should route_to("talk/sessions#index")    
    end
    
    it "should routes to #create" do
      post("/talk/sessions").should route_to("talk/sessions#create")
    end
    
    it "should routes to #show" do
      get("/talk/sessions/1").should route_to("talk/sessions#show", id: "1")
    end
    
    it "should routes to #destroy" do
      delete("/talk/sessions/1").should route_to("talk/sessions#destroy", id: "1")
    end
    
    it "should routes to #make_current" do
      post("/talk/sessions/1/make_current").should route_to("talk/sessions#make_current", id: "1")
    end
    
    it "should routes to #clear_current" do
      delete("/talk/sessions/clear_current").should route_to("talk/sessions#clear_current")
    end
    
    it "should routes to #pull" do
      get("/talk/sessions/pull").should route_to("talk/sessions#pull")
    end
    
    it "should routes to #fetch" do
      get("/talk/sessions/fetch").should route_to("talk/sessions#fetch")
    end
  end
end
