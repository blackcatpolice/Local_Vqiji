require 'spec_helper'

describe DepartmentsController do
  describe "routing" do
    it "should routes to #index" do
      get("/departments").should route_to("departments#index")
    end
    
    it "should routes to #flat" do
      get("/departments/flat").should route_to("departments#flat")
    end
    
    it "should routes to #members" do
      get("/departments/1/members").should route_to("departments#members", id: "1")
    end
  end
end
