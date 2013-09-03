# encoding: utf-8

# 当前用户的主页
class DownloadController < WeiboController
  
  def download
    att =  Attachment::Base.desc("created_at").last.file
    #send_file '/path/to.jpeg', :type => att.file.extension, :disposition => 'inline'
  end
  
end