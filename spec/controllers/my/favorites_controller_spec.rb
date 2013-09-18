require 'spec_helper'

describe My::FavoritesController do
  before(:each) do
    @user = create :user
  end
  
  before(:each) { sign_in @user }

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
    
    it 'should assign @favorites' do
      create :favorite, :user => @user
      get 'index'
      assigns[:favorites].should == @user.favorites
    end
  end

  describe "GET 'index_untagged'" do
    it "returns http success" do
      get 'index_untagged'
      response.should be_success
    end
    
    it 'should assign @favorites' do
      create :favorite, :user => @user
      get 'index_untagged'
      assigns[:favorites].should == @user.favorites
    end
  end

  describe "GET 'index_tagged'" do
    it "returns http success" do
      get 'index_tagged', :tag => 'mytag'
      response.should be_success
    end
    
    it 'should assign @favorites' do
      create :favorite, :user => @user, :tags => 'mytag'
      get 'index_tagged', :tag => 'mytag'
      assigns[:favorites].should == @user.favorites
    end
  end
  
  describe "POST 'create'" do
    before :each do
      @tweet = create :tweet
    end
    
    def post_create
      post 'create', {
        tweet_id: @tweet.to_param,
        format: :json
      }
    end
  
    it "returns http success" do
      post_create
      response.should be_success
    end
    
    it "should create favorite" do
      lambda {
        post_create
      }.should change(Favorite, :count).by(1)
      @user.favorite_service.of(@tweet).should_not be_nil
    end
    
    it "should assign @favorite" do
      post_create
      assigns[:favorite].should == @user.favorite_service.of(@tweet)
    end
  end
  
  describe "POST 'set_tags'" do
    before :each do
      @tweet = create :tweet
      @favorite = create :favorite, :user => @user, :tweet => @tweet
    end
    
    def post_set_tags
      post 'set_tags', {
        tweet_id: @tweet.to_param,
        tags: '1,2,3',
        format: :json
      }
    end
  
    it "returns http success" do
      post_set_tags
      response.should be_success
    end
  end
  
  describe "DELETE 'destroy'" do
    before :each do
      @tweet = create :tweet
      @favorite = create :favorite, :user => @user, :tweet => @tweet
    end
    
    def delete_destroy
      post 'destroy', {
        tweet_id: @tweet.to_param,
        format: :json
      }
    end
  
    it "returns http success" do
      delete_destroy
      response.should be_success
    end
    
    it "should destroy favorite" do
      lambda {
        delete_destroy
      }.should change(Favorite, :count).by(-1)
      @user.favorite_service.of(@tweet).should be_nil
    end
  end

  describe "GET 'set_tags_tip'" do
    before :each do
      @tweet = create :tweet
    end
    
    def get_set_tags_tip
      get 'set_tags_tip', {
        tweet_id: @tweet.to_param
      }
    end
  
    it "returns http success" do
      get_set_tags_tip
      response.should be_success
    end
    
    it 'should assign @tags' do
      create :favorite_tag, :user => @user, :tag => 'Hi'
      get_set_tags_tip
      assigns[:tags].should == [ 'Hi' ]
    end
  end
end
