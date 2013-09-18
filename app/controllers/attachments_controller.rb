# encoding: utf-8

# 附件的上传和下载,删除
# 录音，图片，文件
class AttachmentsController < WeiboController

  # 上传音频附件
  def audio
    begin
      # 如果使用 form data 上传
      if request.form_data?
        _file = params[:file] || (params[:tmp_audio] && params[:tmp_audio][:file])
      else # 否则假设使用 octect-stream 上传
        _file = Tempfile.new(['foo', '.mp3'])
        _file.binmode
        _file.write(request.raw_post)
      end

      _tmp = Attachment::Audio.new(:file => _file, :uploader => current_user)
    ensure
      if _file
        _file.close
        _file.unlink # 删除文件
      end
    end
    _tmp.save!
    respond_to do |format|
      format.json { render_inline_json _tmp.to_json }
    end
  end
  
  #上传文件附件
  def file
    _file = (params[:file] && params[:file][:file])
    @file = Attachment::File.new do |file|
      if _file
        file.file = _file
        file.name = _file.original_filename
      end
      file.uploader = current_user
    end
    if @file.save
      respond_to do |format|
        format.json { render_inline_json @file.to_json }
      end
    else
      respond_to do |format|
        format.json {
          raise WeiboError, @file.errors.full_messages.join(',')
        }
      end
    end
  end
  
  #上传病历
  def history
    _file = params[:tmp_file][:file];
    @tmp = Attachment::NetworkDisk.create!(:file => _file,
      :name => _file.original_filename,
      :uploader_id => current_user.id,
      :upload_type => Attachment::NetworkDisk::TYPE_HISTORY
    )
    respond_to do |format|
      format.json { render_inline_json @tmp.to_json }
    end
  end

  # 上传图片附件
  def picture
    _file = params[:picture] && params[:picture][:file]
    @picture = Attachment::Picture.new do |picture|
      if _file
        picture.file = _file
        picture.name = _file.original_filename
      end
      picture.uploader = current_user
    end
    if @picture.save
      respond_to do |format|
        format.json { render_inline_json @picture.to_json }
      end
    else
      respond_to do |format|
        format.json {
          raise WeiboError, @picture.errors.full_messages.join(',')
        }
      end
    end
  end
  
  # 编辑器上传图片
  def kindsoft_picture
    @picture = Attachment::Picture.new do |picture|
      picture.file = (params[:picture] && params[:picture][:file])
      picture.uploader = current_user
    end
    if @picture.save
      data = { :error => 0, :url => @picture.file.url }
      render :json =>  data 
    else
      data = { :error => 1, :message => @picture.errors.full_messages.join(',') }
      render :json => data
    end
  end
  
  DOWNLOAD_ABLE_TYPES = [
    Attachment::Audio,
    Attachment::File,
    Attachment::Picture
  ].collect { |model|
      model._types
    }.flatten!.freeze

  # 下载附件
  def download
    @file = Attachment::Base.where(:_type.in => DOWNLOAD_ABLE_TYPES).find(params[:id])
    x_send_file @file.path, :filename => (@file.name || @file.filename)
  end

  def destroy
    @file = Attachment::Base.find(params[:id])

    if @file.uploader == current_user
      @file.destroy
      respond_to do |format|
        format.json { render :json => @file }
      end
    else
      raise WeiboError, '滚粗！'
    end
  end

  def case_history
    @histories = Attachment::Base.where(:uploader_id => current_user.id, :upload_type => Attachment::NetworkDisk::TYPE_HISTORY,:status => Attachment::NetworkDisk::FILE_STATUS)
    respond_to do |format|
      format.json { render :json => @histories }
    end
  end
  
  def disks
    @files = Attachment::NetworkDisk.where(:uploader_id => current_user.id, :upload_type => Attachment::NetworkDisk::TYPE_NETWORK_DISK, :status => Attachment::NetworkDisk::FILE_STATUS).desc(:created_at)
    render :json => @files
  end

end
