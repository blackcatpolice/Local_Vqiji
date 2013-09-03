require 'spec_helper'

describe Talk::Realtime::GroupReceiver do
  describe '#[](Group)' do
    subject(:group) { Talk::Realtime::GroupReceiver[create(:talk_group)] }
    
    its(:class) { should == Talk::Group }
    its(:to_realtime_receiver_id) { should == "talk/group/#{ group.to_param }" }
  end
  
  describe '#[](String)' do
    subject(:receiver) { Talk::Realtime::GroupReceiver['1'] }
    
    its(:class) { should == String }
    its(:to_realtime_receiver_id) { should == "talk/group/1" }
  end
end
