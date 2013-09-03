# encoding: utf-8

module TimeagoHelper

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end
  
  def timemsg(time,options = {})
    #l time, :format => :short if time
    return time.strftime("%Y-%m-%d %H:%M:%S") if time
  end

end
