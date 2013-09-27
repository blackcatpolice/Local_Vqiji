# encoding: utf-8

# 任务日志
class Todo::Log
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  belongs_to :user, :class_name => 'User', inverse_of: :todo_logs
  belongs_to :task, :class_name => 'Todo::Task', inverse_of: :logs, :counter_cache => true
  field :info, :type => String # 日志信息
  embeds_one :file, class_name: 'Attachment::File' #文件
  embeds_one :picture, class_name: 'Attachment::Picture'  #图片
  field :old_progress, :type => Integer, :default => 0 # 上个进度
  field :progress, :type => Integer, :default => 0     # 任务进度 百分比 [0-100]
  
  validates_presence_of :user, :task, :info, :old_progress, :progress
  attr_readonly :user, :task, :info, :old_progress, :progress

  default_scope desc(:created_at)
  scope :changed_progress, where('this.progress != this.old_progress')

  public

  def changed_progress?
    progress != old_progress
  end
  
  def set_file(_file)
    if _file.is_a?(Attachment::File)
      _file.update_attributes(:target => self)
    else
      open(_file.path) do |file|
        _file = Attachment::File.create!({
          :file => file,
          :uploader => _file.uploader,
          :name => _file.name
        })
      end
    end
    self.file = _file
  end

  def set_picture(_picture)
    _picture.update_attributes(:target => self)
    self.picture = _picture
  end
end
