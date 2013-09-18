## encoding: utf-8
##
##
class Admin::AttachmentsController < Admin::BaseController

  layout proc { |controller| controller.request.xhr? ? nil : 'layouts/administrator' }

  def home
  end

  def index
    @attachments = Attachment::Base.desc(:created_at)
      .paginate(:page => params[:page], :per_page => 10)
  end

  def files
    @attachments = Attachment::File.desc(:created_at)
      .paginate(:page => params[:page], :per_page => 10)
  end
  
  def download
    file = Attachment::Base.find(params[:id])
    x_send_file(file.path, :filename => file.name || file.filename)
  end
end
