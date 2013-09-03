require 'spec_helper'

describe Realtime::Trigger do
  let(:trigger) { Realtime::Trigger.new('alert', 'This is body') }
  
  describe 'attributes' do
    subject { trigger }
    
    its(:callback) { should == 'alert' }
    its(:params) { should == 'This is body' }
  end
  
  describe '#to_trigger_param' do
    let(:result) { JSON.parse(trigger.to_trigger_param) }
    it "should has key 'callback'" do
      result['callback'].should == 'alert'
    end
    it "should has key 'params'" do
      result['params'].should == 'This is body'
    end
  end
  
  describe '#throw_to!' do
    it 'should works with Realtime::GlobalReceiver' do
      receiver = Realtime::GlobalReceiver
      $redis.should_receive(:publish).once.with('realtime/global/trigger', trigger.to_trigger_param)
      trigger.throw_to!(receiver)
    end
    
    it 'should works with Realtime::UserReceiver' do
      receiver = Realtime::UserReceiver[create(:user)]
      $redis.should_receive(:publish).once.with("realtime/private/#{receiver.to_param}/trigger", trigger.to_trigger_param)
      trigger.throw_to!(receiver)
    end
  end
  
  describe '#throw_to_global!' do
    it 'should call #throw_to! with Realtime::GlobalReceiver' do
      trigger.should_receive(:throw_to!).once.with(Realtime::GlobalReceiver)
      trigger.throw_to_global!
    end
  end
end
