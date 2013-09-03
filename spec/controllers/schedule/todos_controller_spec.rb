require 'spec_helper'

describe Schedule::TodosController do
  let(:valid_attributes) { attributes_for :schedule_todo }
  let(:valid_session) { {} }
  let(:current_user) { create :user }

  before :each do
    sign_in current_user
  end

  describe 'POST "create"' do
    it "returns http success" do
      post 'create', todo: valid_attributes
      response.should be_success
    end

    it "should create todo" do
      post 'create', todo: valid_attributes
      assigns[:todo].should be_persisted
      assigns[:todo].should be_an_instance_of Schedule::Todo
    end
  end

  describe 'DELETE "destroy"' do
    let(:todo) { create :schedule_todo, user: current_user }
  
    it "returns http success" do
      delete 'destroy', { id: todo.to_param }
      response.should be_success
    end

    it "should destroy todo" do
      delete 'destroy', { id: todo.to_param }
      assigns[:todo].should == todo
      assigns[:todo].should be_deleted
    end
  end

  describe 'GET "month_count"' do
    it "returns http success" do
      get 'month_count', { month: '2013/6' }
      response.should be_success
    end
  end
  
  describe 'GET "fullday"' do
    it "returns http success" do
      get 'fullday', { date: '2013-6-5' }
      response.should be_success
    end
    
    it "should assign @tasks" do
      get 'fullday', { date: '2013-6-5' }
      assigns[:todos].should_not be_nil
    end
  end

end
