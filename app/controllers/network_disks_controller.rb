#coding: utf-8
class NetworkDisksController < WeiboController
  require 'zipruby'
  layout proc { |c| pjax_request? ? pjax_layout : 'network_disk' }
  #网盘
  def index
    @files = Attachment::NetworkDisk.where(:uploader_id => current_user.id, :status => Attachment::NetworkDisk::FILE_STATUS)
      .in(upload_type: [Attachment::NetworkDisk::UPLOAD_TYPE_HISTORY, Attachment::NetworkDisk::UPLOAD_TYPE_NETWORK_DISK])
      .desc(:created_at).paginate :page => params[:page], :per_page => params[:size] || 10

    respond_to do |format|
      format.html
      format.json { render :json => @files}
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

  #上传文件
  def upload
    upload_type = params[:upload_type] == Attachment::NetworkDisk::UPLOAD_TYPE_HISTORY ? Attachment::NetworkDisk::UPLOAD_TYPE_HISTORY : Attachment::NetworkDisk::UPLOAD_TYPE_NETWORK_DISK 
    _file = params[:disk][:file];
    _tmp = Attachment::NetworkDisk.create!(
      :file => _file,
      :name => _file.original_filename,
      :uploader_id => current_user.id,
      :upload_type => upload_type
    )
    respond_to do |format|
      format.html{
        render :partial => "network_disks/file", :locals => {:file => _tmp}
      }
      format.json { render :json => _tmp}
    end
  end
  
  def destroy
    data = {:status => 200, :msg => "删除成功"}
    file = Attachment::NetworkDisk.find(params[:id])
    if(file.uploader_id != current_user.id)
      raise WeiboError.new("您没有权限删除文件!")
    end
    file.update_attribute('status', Attachment::NetworkDisk::FILE_STATUS_DELETE) if file
    respond_to do |format|
      format.json{
        render :json => data
      }
    end
  end
  
  def rename
    data = {:status => 200, :msg => "命名成功!"}
    file = Attachment::NetworkDisk.find(params[:id])
    if params[:name].blank?
      raise WeiboError.new("请输入文件名!")
    end
    if file.uploader_id != current_user.id
      raise WeiboError.new("您没有权限重命名文件!")
    end
    file.update_attribute('name', params[:name] + "#{File.extname(file.name)}")
    data[:new_name] = file.name
    render :json => data
  end

  def destroy_list
    Attachment::NetworkDisk.where(uploader_id: current_user.id).in(_id: params[:fid]).update_all(:status => Attachment::NetworkDisk::FILE_STATUS_DELETE)
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
    @share_file = Attachment::NetworkDisk.where(_id: params[:fid]).first
    
    if @share_file.blank? || @share_file.status == Attachment::NetworkDisk::FILE_STATUS_DELETE
      render :text => "您要分享的文件不存在!"
    else
      unless @share_file.uploader_id == current_user.id
        render :text => "您没有权限分享此文件!"
      else
        render :layout => false 
      end
    end
  end

  def message
    @share_file = Attachment::NetworkDisk.where(_id: params[:fid]).first
    
    if @share_file.blank? || @share_file.status == Attachment::NetworkDisk::FILE_STATUS_DELETE
      render :text => "您要分享的文件不存在!"
    else
      unless @share_file.uploader_id == current_user.id
        render :text => "您没有权限分享此文件!"
      else
        render :layout => false 
      end
    end
  end
  
  
  #文件加密
  def encrypt
    _tmp = Attachment::NetworkDisk.find(params[:id])
    chdir, tardir = File.split(_tmp.file.path)

    if params[:encrypt].blank?
      raise WeiboError.new("请输入文件加密密码.")
    end
    if params[:encrypt].length < 6 || params[:encrypt].length > 16
      raise WeiboError.new("密码由6－16位数字、字母和常用符号组成.")
    end
    if _tmp.size > 10485760
      raise WeiboError.new("加密文件最大为10M.")
    end
    if _tmp.blank? || _tmp.status == Attachment::NetworkDisk::FILE_STATUS_DELETE
      raise WeiboError.new("文件不存在, 不能加密.")
    end
    if _tmp.encrypt || File.exist?("#{chdir}/encrypt.zip")
      raise WeiboError.new("加密失败, 已加密文件不可重复加密.")
    end
    if _tmp.uploader_id != current_user.id
      raise WeiboError.new("你没有权限对文件加密!")
    end
    file_path = open(_tmp.file.path)
    Zip::Archive.open("#{chdir}/encrypt.zip", Zip::CREATE) do |ar|
      ar << file_path
      ar.encrypt(params[:encrypt])
    end

    _tmp.encrypt = true
    _tmp.save
    File.delete(_tmp.file.path)
    
    respond_to do |format|
      format.html{
        render :partial => "network_disks/file", :locals => {:file => _tmp}
      }
      format.json { render :json => _tmp}
    end
  end
  
  #收藏文件
  def collect
    collect_tmp = Attachment::Base.where(:_id => params[:id]).first
    if collect_tmp.encrypt
      raise WeiboError.new("文件已被加密, 不能收藏.")
    end
    if collect_tmp.blank?
      raise WeiboError.new("文件不存在, 或已删除.")
    end
    p collect_tmp.file
    upload_type = params[:upload_type] == Attachment::NetworkDisk::UPLOAD_TYPE_HISTORY ? Attachment::NetworkDisk::UPLOAD_TYPE_HISTORY : Attachment::NetworkDisk::UPLOAD_TYPE_NETWORK_DISK 
    _tmp = Attachment::NetworkDisk.create!(
      :file => collect_tmp.file,
      :name => collect_tmp.name || collect_tmp.filename,
      :uploader_id => current_user.id,
      :upload_type => upload_type
    )
    render :json => _tmp
  end
end
