require 'spec_helper'

describe Talk::MessagesController do
  describe "routing" do
    it "should routes to #index" do
      get("/talk/sessions/1/messages").should route_to("talk/messages#index", session_id: "1")
    end
    
    it "should routes to #create" do
      post("/talk/sessions/1/messages").should route_to("talk/messages#create", session_id: "1")
    end
    
    it "should routes to #rt_create" do
      post("/talk/sessions/1/messages/rt_create").should route_to("talk/messages#rt_create", session_id: "1")
    end
    
    it "should routes to #show" do
      get("/talk/messages/1").should route_to("talk/messages#show", id: "1")
    end
    
    it "should routes to #destroy" do
      delete("/talk/messages/1").should route_to("talk/messages#destroy", id: "1")
    end
    
    it "should routes to #unread_count" do
      get("/talk/sessions/1/messages/unread_count").should route_to("talk/messages#unread_count", session_id: "1")
    end

    it "should routes to #unreads" do
      get("/talk/sessions/1/messages/unreads").should route_to("talk/messages#unreads", session_id: "1")
    end
    
    it 'should routes to #new_modal_to_user' do
      get("/talk/messages/to_u/1/new_modal").should route_to('talk/messages#new_modal_to_user', :user_id => "1")
    end
    
    it 'should routes to #create_to_user' do
      post("/talk/messages/to_u/1").should route_to('talk/messages#create_to_user', :user_id => "1")
    end
  end
end
