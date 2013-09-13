require 'spec_helper'

describe Favorite do
  describe Favorite::Service do
    let(:user) { create :user }
    let(:tweet) { create :tweet }
    
    it "should favorite/unfavorite!" do
      user.favorite?(tweet).should be_false

      user.favorite(tweet)
      user.favorite?(tweet).should be_true

      user.unfavorite!(tweet)
      user.favorite?(tweet).should be_false
    end
    
    it 'should set favorite tag' do
      user.favorite(tweet, 'my-tag')
      user.favorite_service.of(tweet).tag.should == 'my-tag'
    end
    
  end
end

