require 'spec_helper'

describe Realtime::UserReceiver do
  describe '#[](User)' do
    subject(:receiver) { Realtime::UserReceiver[create(:user)] }
    
    its(:class) { should == User }
    its(:to_realtime_receiver_id) { should == "private/#{ receiver.to_param }" }
  end
  
  describe '#[](String)' do
    subject(:receiver) { Realtime::UserReceiver['1'] }
    
    its(:class) { should == String }
    its(:to_realtime_receiver_id) { should == "private/1" }
  end
end
