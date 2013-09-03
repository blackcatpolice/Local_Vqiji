require 'spec_helper'

describe UsersController do
  describe "routing" do
    it "should routes to #show" do
      get("/users/1").should route_to("users#show", id: "1")
    end
    
    it "should routes to #followeds" do
      get("/users/1/followeds").should route_to("users#followeds", id: "1")
    end
    
    it "should routes to #fans" do
      get("/users/1/fans").should route_to("users#fans", id: "1")
    end
    
    it "should routes to #search" do
      get("/users/search").should route_to("users#search")
    end
    
    it "should routes to #card" do
      get("/users/1/card").should route_to("users#card", id: '1')
    end
  end
end
