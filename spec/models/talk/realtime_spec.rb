# encoding: utf-8

require 'spec_helper'

describe Talk::Realtime do
  describe 'Manage current session' do
    let(:session) { create :talk_session }
    let(:current_user) { session.user }
    
    it '#set_current_session' do    
      $redis.should_receive(:hset).once.with(Talk::Realtime::CURRENT_SESSION_KEY, current_user.to_param, session.to_param)
      Talk::Realtime.set_current_session(current_user, session)
    end
    
    it '#clear_current_session' do    
      $redis.should_receive(:hset).once.with(Talk::Realtime::CURRENT_SESSION_KEY, current_user.to_param, nil)
      Talk::Realtime.clear_current_session(current_user)
    end
    
    it '#current_session' do
      $redis.should_receive(:hget).once.with(Talk::Realtime::CURRENT_SESSION_KEY, current_user.to_param).and_return(session.to_param)
      Talk::Realtime.current_session(current_user).should == session
    end
  end
end
