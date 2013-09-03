# encoding: utf-8
require 'spec_helper'

describe Rt::Tokenize do
  let(:user) { FactoryGirl.create(:user) }
  
  it "should tokenize topic" do
    tokens = Rt::Tpr.tokenizer.tokenize('#新闻联播#')
    tokens.length.should eq(1)
    tokens[0].should be_an_instance_of(Rt::Tpr)
    tokens[0].title.should == '新闻联播'
  end
  
  it "should tokenize emotion" do
    tokens = Rt::Emo.tokenizer.tokenize('[囧]')
    tokens.should have(1).items
    tokens[0].should be_an_instance_of(Rt::Emo)
    tokens[0].code.should == '囧'
  end
  
  it "should tokenize mention" do
    tokens = Rt::Met.tokenizer.tokenize("@#{user.name} ")
    tokens.should have(1).items
    tokens[0].should be_an_instance_of(Rt::Met)
    tokens[0].uid.should == user.id
    tokens[0].name.should == user.name
  end
  
  it "should tokenize url" do
    tokens = Rt::Url.tokenizer.tokenize('http://126.am')
    tokens.should have(1).items
    tokens[0].should be_an_instance_of(Rt::Url)
    tokens[0].url.should == 'http://126.am/WuAwB4'
  end

  it "should tokenize text" do
    tokens = Rt::Txt.tokenizer.tokenize('普通文本')
    tokens.should have(1).items
    tokens[0].should be_an_instance_of(Rt::Txt)
    tokens[0].text.should == '普通文本'
  end
  
  it "shoud keep tokens order" do
    text = '#新版发布#元素测试通过，视频庆祝http://www.tudou.com/albumcover/6YJO9on_c38.html[给力]@%s 更多信息http://www.google.com' % user.name
    tokens = Rt.tokenize(text, [Rt::Emo, Rt::Met, Rt::Tpr, Rt::Url, Rt::Txt])
    tokens.should have(7).items
    tokens[0].should be_an_instance_of(Rt::Tpr)
    tokens[1].should be_an_instance_of(Rt::Txt)
    tokens[2].should be_an_instance_of(Rt::Vurl)
    tokens[3].should be_an_instance_of(Rt::Emo)
    tokens[4].should be_an_instance_of(Rt::Met)
    tokens[5].should be_an_instance_of(Rt::Txt)
    tokens[6].should be_an_instance_of(Rt::Url)
  end
end
