# coding: utf-8
require 'zipruby'

class NetworkDisksController < WeiboController
  layout proc { |c| pjax_request? ? pjax_layout : 'network_disk' }
  
  # 网盘
  def index
    @files = current_user.attachments.network_disks.where(:status => Attachment::NetworkDisk::FILE_STATUS)
      .in(upload_type: [Attachment::NetworkDisk::TYPE_HISTORY, Attachment::NetworkDisk::TYPE_NETWORK_DISK])
      .desc(:created_at).paginate(:page => params[:page], :per_page => params[:size] || 10)

    respond_to do |format|
      format.html
      format.json { render :json => @files }
    end
  end

  prepend_before_filter :set_flash_session, :only => :upload
  
  protected

    def set_flash_session
      if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/ or env['HTTP_REFERER'] =~ /.swf/
        req = Rack::Request.new(env)
        the_session_key = [ @session_key, req.params[@session_key] ].join('=').freeze if req.params[@session_key]

        if req.params['remember_token'] && req.params['remember_token'] != 'null'
          the_remember_token = [ 'remember_token', req.params['remember_token'] ].join('=').freeze
        else
          the_remember_token = nil
        end

        cookie_with_remember_token_and_session_key = [ the_remember_token, the_session_key ].compact.join('\;').freeze

        env['HTTP_COOKIE'] = cookie_with_remember_token_and_session_key
        env['HTTP_ACCEPT'] = "#{req.params['_http_accept']}".freeze if req.params['_http_accept']
      end
    end

  public

  # 上传文件
  def upload
    upload_type = params[:upload_type] == Attachment::NetworkDisk::TYPE_HISTORY ? Attachment::NetworkDisk::TYPE_HISTORY : Attachment::NetworkDisk::TYPE_NETWORK_DISK 
    _file = params[:disk][:file];
    _tmp = Attachment::NetworkDisk.create!(
      :file => _file,
      :name => _file.original_filename,
      :uploader => current_user,
      :upload_type => upload_type
    )
    respond_to do |format|
      format.html{
        render :partial => 'network_disks/file', :locals => {:file => _tmp}
      }
      format.json { render :json => _tmp}
    end
  end
  
  def destroy
    file = current_user.attachments.network_disks.find(params[:id])
    file.update_attribute(:status, Attachment::NetworkDisk::FILE_STATUS_DELETE) if file
    render :json => {
      :status => 200,
      :msg => '删除成功!'
    }
  end
  
  def rename
    file = current_user.attachments.network_disks.find(params[:id])
    if params[:name].blank?
      raise WeiboError.new('请输入文件名!')
    end
    file.update_attribute(:name, params[:name] + "#{File.extname(file.name)}")
    render :json => {
      :status => 200,
      :msg => '重命名成功!',
      :new_name => file.name
    }
  end

  def destroy_list
    current_user.attachments.network_disks
      .in(_id: params[:fid]).update_all(:status => Attachment::NetworkDisk::FILE_STATUS_DELETE)
    respond_to do |format|
      format.html { redirect_to network_disks_path, notice: '删除成功!' }
    end
  end
  
  def swfupload_widget
    render :layout => false
  end
  
  def swfupload
    render :layout => false
  end
  
  def history
    render :layout => false
  end
  
  def share
    @share_file = current_user.attachments.network_disks.where(_id: params[:fid]).first
    
    if !@share_file || (@share_file.status == Attachment::NetworkDisk::FILE_STATUS_DELETE)
      render :text => "您要分享的文件不存在!" and return
    end
    render :layout => false
  end

  def message
    @share_file = current_user.attachments.network_disks.where(_id: params[:fid]).first
    
    if !@share_file || (@share_file.status == Attachment::NetworkDisk::FILE_STATUS_DELETE)
      render :text => "您要分享的文件不存在!" and return
    end
    render :layout => false
  end
  
  # 文件加密
  def encrypt
    _file = current_user.attachments.network_disks.find(params[:id])

    if params[:encrypt].blank?
      raise WeiboError.new("请输入文件加密密码.")
    end

    _file.encrypt!(params[:encrypt])
    
    respond_to do |format|
      format.html{
        render :partial => "network_disks/file", :locals => { :file => _file }
      }
      format.json { render :json => _file }
    end
  end

  def download
    file = current_user.attachments.network_disks.find(params[:network_disk_id])
    send_file file.path, :filename => (file.name || file.filename), :x_sendfile => true
  end
  
  # 收藏文件
  def collect
    collect_tmp = Attachment::File.find(params[:id])
    upload_type = params[:upload_type] == Attachment::NetworkDisk::TYPE_HISTORY ? Attachment::NetworkDisk::TYPE_HISTORY : Attachment::NetworkDisk::TYPE_NETWORK_DISK 
    @file = Attachment::NetworkDisk.create!({
      :file => collect_tmp.file,
      :name => collect_tmp.name || collect_tmp.filename,
      :uploader => current_user,
      :upload_type => upload_type
    })
    render :json => @file.to_json
  end
end
