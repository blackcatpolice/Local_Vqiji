# encoding: utf-8

require 'tempfile'

# 网盘
class Attachment::NetworkDisk < Attachment::Base
  TYPE_HISTORY = 'HISTORY' # 病历
  TYPE_NETWORK_DISK = 'NETWORK_DISK' # 网盘

  FILE_STATUS = 1
  FILE_STATUS_DELETE = 0

  mount_uploader :file, NetworkDiskUploader, mount_on: :filename

  field :name, type: String # 文件名
  field :size, type: Integer, default: 0 # size in byte
  field :encrypt, type: Boolean, default: false # 默认不加密
  field :status, type: Integer, default: FILE_STATUS
  field :upload_type, default: TYPE_NETWORK_DISK
  
  attr_readonly :size
  # validates :file, presence: true, file_size: { maximum: 5.megabytes.to_i }
  
  before_create do |attachment|
    attachment.size = attachment.file.size
  end
  
  delegate :url, :path, :to => :file
  
  def encrypt!(password)
    raise WeiboError.new('文件不存在, 不能加密.') if (!file.present? || status == Attachment::NetworkDisk::FILE_STATUS_DELETE)
    raise WeiboError.new('已加密文件不可重复加密.') if encrypt
    raise WeiboError.new('密码由6-16位数字、字母、下划线和常用符号(!@#$%^&*)组成.') unless (password =~ /^[0-9a-zA-Z_!@#\$%^&*]{6,16}$/)
    raise WeiboError.new('加密文件最大为10M.') if (size > 10 * 1024 * 1024)

    _tmp = Tempfile.new(['encrypt', '.zip'])

    begin
      Zip::Archive.open(_tmp.path, Zip::CREATE) do |ar|
        ar.add_file(name || filename, path)
        ar.encrypt(password)
      end
      
      self.file = _tmp
      self.name = "#{name || filename}_encrypted.zip"
      self.encrypt = true

      self.save!
    ensure
      _tmp.close(true)
    end
  end

  def to_builder
    super do |base|
      base.(self, :name, :size, :url)
    end
  end
end
