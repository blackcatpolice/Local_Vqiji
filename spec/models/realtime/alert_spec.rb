require 'spec_helper'

describe Realtime::Alert do
  let(:alert) { Realtime::Alert.new('alert-body', 'alert-title') }
  
  describe 'attributes' do
    subject { alert }
    
    its(:body) { should == 'alert-body' }
    its(:title) { should == 'alert-title' }

    it 'should set title as default' do
      Realtime::Alert.new('alert-body').title.should == I18n.t('realtime.alert.title')
    end
  end
  
  describe '#throw_to!' do
    it 'should works with Realtime::GlobalReceiver' do
      receiver = Realtime::GlobalReceiver
      $redis.should_receive(:publish).once.with('realtime/global/trigger', alert.to_trigger_param)
      alert.throw_to!(receiver)
    end
    
    it 'should works with Realtime::UserReceiver' do
      receiver = Realtime::UserReceiver[create(:user)]
      $redis.should_receive(:publish).once.with("realtime/private/#{receiver.to_param}/trigger", alert.to_trigger_param)
      alert.throw_to!(receiver)
    end
  end
  
  describe '#throw_to_global!' do
    it 'should call #throw_to! with Realtime::GlobalReceiver' do
      alert.should_receive(:throw_to!).once.with(Realtime::GlobalReceiver)
      alert.throw_to_global!
    end
  end
end
