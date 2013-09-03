## encoding: utf-8
##
##
class Admin::AttachmentsController < Admin::BaseController

  layout proc { |controller| controller.request.xhr? ? nil : 'layouts/administrator' }

  def home

  end

  def index
    @attachments = Attachment::Base.all.desc("created_at").paginate :page => params[:page], :per_page => 10
  end

  def files
    @attachments = Attachment::File.all.desc("created_at").paginate :page => params[:page], :per_page => 10
  end
  
  def download
    att = Attachment::Base.find(params[:id])
    #render :text=>att.file.url
    url = "#{att.file.path}"
    #render :text=>url
    send_file(url,:filename=>att.name || att.filename)
  end
  
end