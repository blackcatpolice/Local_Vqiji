# encoding: utf-8

require 'spec_helper'

describe Rt::Url do
  LONG_URL = 'http://www.google.com/'
  SHORT_URL = 'http://126.am/RpP4x1'

  it "should get short url" do
    Rt::Url.shorten(LONG_URL).should == SHORT_URL
  end
  
  it "should get origin url" do
    Rt::Url.shorten(SHORT_URL).should == SHORT_URL
  end
  
  it "should expand short url" do
    Rt::Url.expand(SHORT_URL).should == LONG_URL
  end
  
  it "should not expand origin url" do
    Rt::Url.expand(LONG_URL).should == LONG_URL
  end
  
  it "should valid url" do
    Rt::Url.valid?(LONG_URL).should be_true
  end
  
  it "should discern tudou video url" do
    url = Rt::Url.discern('http://www.tudou.com/albumcover/6YJO9on_c38.html')
    url.should be_an_instance_of(Rt::Url::TudouVideo)
  end
  
  it "识别 youku 视频链接" do
    url = Rt::Url.discern('http://v.youku.com/v_show/id_XNTQ5ODk3ODU2.html')
    url.should be_an_instance_of(Rt::Url::YoukuVideo)
  end
end
