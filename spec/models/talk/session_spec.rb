# encoding: utf-8
require 'spec_helper'

describe Talk::Session do
  it "#say" do
    session = create :talk_session
    lambda {
      session.say("发信息").should
    }.should change(Talk::Message::User, :count).by(1)
  end
end
