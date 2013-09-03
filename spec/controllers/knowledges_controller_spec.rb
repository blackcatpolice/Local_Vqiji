require "spec_helper"

describe KnowledgesController do
  
  let(:current_user){ create :user }
  
  before do
    sign_in current_user
  end
  
  describe "Get Index" do
    
    it "response success with status 200" do
      get :index
      expect(response.status).to eq(200)
    end
    
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
    
    it "index.json" do
      get :index, :format => :json
    end 
    
  end
  
  describe "GET Show" do
    
  end
  
end

