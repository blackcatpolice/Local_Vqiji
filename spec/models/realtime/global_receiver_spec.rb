require 'spec_helper'

describe Realtime::GlobalReceiver do
  subject { Realtime::GlobalReceiver }

  its(:to_realtime_receiver_id) { should == 'global' }
end
