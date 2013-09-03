require "spec_helper"

describe Schedule::TodosController do
  describe "routing" do
    it "routes to #range_count" do
      get("/schedule/2013%2F6/todos/count").should route_to("schedule/todos#month_count", :month => '2013/6')
    end

    it "routes to #fullday" do
      get("/schedule/2013%2F6%2F5/todos").should route_to("schedule/todos#fullday", :date => '2013/6/5')
    end
    
    it "routes to #create" do
      post("/schedule/todos").should route_to("schedule/todos#create")
    end
    
    it "routes to #destroy" do
      delete("/schedule/todos/1").should route_to("schedule/todos#destroy", :id => "1")
    end
  end
end
