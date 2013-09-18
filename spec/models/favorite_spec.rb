require 'spec_helper'

describe Favorite do
  describe Favorite::Service do
    let(:user) { create :user }
    let(:tweet) { create :tweet }
    
    it "should #favorite" do
      user.favorite?(tweet).should be_false
      lambda {
        user.favorite(tweet)
      }.should change(Favorite, :count).by(1)
      user.favorite?(tweet).should be_true

      user.unfavorite!(tweet)
      user.favorite?(tweet).should be_false
    end
    
    it "should #unfavorite!" do
      user.favorite(tweet)
      user.favorite?(tweet).should be_true
      lambda {
        user.unfavorite!(tweet)
      }.should change(Favorite, :count).by(-1)
      user.favorite?(tweet).should be_false
    end
    
    it 'should #set_tags!' do
      _favorite = user.favorite(tweet)
      user.favorite_service.set_tags!(_favorite, '1,2 , 3')
      _favorite.tags_array.should == [ '1', '2', '3' ]
    end
  end
end

