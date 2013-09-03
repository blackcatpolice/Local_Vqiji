require 'spec_helper'

describe Favorite do
  describe Favorite::Service do
    let(:user) { create :user }
    let(:tweet) { create :tweet }
    
    it "favorite/unfavorite! should works" do
      user.favorite?(tweet).should be_false

      user.favorite(tweet)
      user.favorite?(tweet).should be_true

      user.unfavorite!(tweet)
      user.favorite?(tweet).should be_false
    end
  end
end

