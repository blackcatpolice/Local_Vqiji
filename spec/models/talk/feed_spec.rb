require 'spec_helper'

describe Talk::Feed do
  let(:feed) { build :talk_feed, is_read: false }
  
  it "should increment @message.unread_count by 1 after create" do
    lambda {
      feed.save!
    }.should change(feed.session, :unread_count).by(1)
  end
  
  it "should decrement @message.unread_count by 1 after destroy" do
    feed.save!
    
    lambda {
      feed.destroy
    }.should change(feed.session, :unread_count).by(-1)
  end
  
  it "should decrement @message.unread_count by 1 after read" do
    feed.save!

    lambda {
      feed.session.read([feed])
    }.should change(feed.session, :unread_count).by(-1)
  end

end
