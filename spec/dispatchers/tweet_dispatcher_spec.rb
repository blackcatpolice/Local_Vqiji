require 'spec_helper'

describe Tweet::Dispatcher do
  it "#perform" do
    tweet = create :tweet
    # tweet.should_receive(:dispatch).once
    Tweet.any_instance.should_receive(:dispatch).once
    Tweet::Dispatcher.perform(tweet.to_param)
  end
end
