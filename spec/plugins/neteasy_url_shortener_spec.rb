# encoding: utf-8

require 'spec_helper'

describe Neteasy::UrlShortener do
  LONG_URL    = "http://www.google.com/"
  SHORTEN_URL = "http://126.am/RpP4x1"
  
  it "#shorten!" do
    Neteasy::UrlShortener.shorten!(LONG_URL).should == SHORTEN_URL
  end

  it "#expand!" do
    Neteasy::UrlShortener.expand!(SHORTEN_URL).should == LONG_URL
  end
end
