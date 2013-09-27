# encoding: utf-8

# 任务
class Todo::Task
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ActiveModel::ForbiddenAttributesProtection
  
  # 优先级
  PRIORITY_NORMAL      = 0 # 普通
  PRIORITY_IMPORTANT   = 1 # 待确认
  PRIORITY_EMERGENCY   = 2 # 紧急

  # 基础字段
  field :title, :type => String # 标题
  field :details, :type => String # 详细
  embeds_one :file, class_name: 'Attachment::File' #文件
  embeds_one :picture, class_name: 'Attachment::Picture' #图片
  belongs_to :creator,  :class_name => 'User', inverse_of: :created_todo_tasks, index: true # 任务创建人
  belongs_to :executor, :class_name => 'User', inverse_of: :todo_tasks, index: true # 任务执行者  
  field :priority, :type => Integer, :default => PRIORITY_NORMAL
  field :start_at, :type => DateTime, default: -> { Time.now.utc } # 开始日期
  field :end_at,   :type => DateTime    # 结束日期

  # 状态
  field :is_new, :type => Boolean,   :default => true  # 是否是新任务
  field :progress, :type => Integer, :default => 0 # 进度, 0-100
  field :completed_at, :type => DateTime  # 完成时间, 任务进度改为100％的修改时间
  field :confirmed_at,   :type => DateTime  # 确认完成时间

  # 任务层级
  belongs_to :sup, :class_name => 'Todo::Task', inverse_of: :subs, counter_cache: true  # 父任务
  has_many  :subs, :class_name => 'Todo::Task', inverse_of: :sup, dependent: :destroy, autosave: true # 子任务
  field :subs_count, :type => Integer, :default => 0 # 子任务数量
  
  # 任务日志
  has_many :logs, :class_name => 'Todo::Log', inverse_of: :task, :dependent => :destroy, autosave: true
  
  # validates
  validates :title, presence: true
  validates_presence_of :details, :creator, :executor, :priority, :start_at, :end_at
  validates :priority, presence: true, inclusion: { in: [PRIORITY_NORMAL, PRIORITY_IMPORTANT, PRIORITY_EMERGENCY] }
  validates :progress, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  # 结束时间必须大于开始时间
  validates_each :end_at, allow_blank: true do |task, attr, value|
    task.errors.add(attr, :must_greater_than_start_at) if(task.end_at <= task.start_at)
  end
  # 标记为以确认时 completed_at 必须设置
  validates :completed_at, presence: true, if: ->(task)  { task.confirmed? }
  
  define_model_callbacks :completed, only: :after
  define_model_callbacks :uncompleted, only: :after
  define_model_callbacks :finished, only: :after

  private
  
  around_save :_around_progress_changed_save, if: ->(task) { !task.finished? && task.progress_changed? } # order=0
  around_save :_around_confirmed_at_changed_save, if: ->(task) { task.confirmed_at_changed? && task.confirmed? } # order=1
  
  def _around_progress_changed_save(&block)
    if (progress == 100)
      # 完成了
      self.completed_at = Time.now.utc
      run_callbacks :completed do
        block.call(self)
      end
    else
      self.completed_at = nil
      if (progress_was == 100)
        # 取消完成状态
        run_callbacks :uncompleted do
          block.call(self)
        end
      else
        block.call(self) 
      end
    end
  end
  
  def _around_confirmed_at_changed_save(&block)
    run_callbacks :finished do
      block.call(self)
    end
  end
  
  public

  # default_scope desc(:created_at)
  scope :uncompleted, where(:completed_at => nil)
  scope :completed, where(:completed_at.ne => nil)
  scope :_untimeout, where('this.end_at >= (this.completed_at || (new Date()))')
  # mongoid 本身有一个方法叫 timeout, 为了解决冲突问题，这里改名为 _timeout
  scope :_timeout, where('this.end_at < (this.completed_at || (new Date()))')
  scope :will_timeout, -> { uncompleted.where(:end_at.gt => 3.days.ago) }
  scope :unconfirmed, where(:confirmed_at => nil)
  scope :confirmed, where(:confirmed_at.ne => nil)
  scope :finished, where(:confirmed_at.ne => nil)

  # 要超时了？
  def will_timeout?
    !completed? && (end_at >= 3.days.ago)
  end
  
  # 超时了？
  def timeout?
    end_at < (completed_at || Time.now)
  end

  # 已经完成？
  def completed?
    !completed_at.nil?
  end
  
  def progress_100?
    progress == 100
  end
  
  # 已经确认完成？
  def confirmed?
    !confirmed_at.nil?
  end
  
  def creator?(user)
    creator == user
  end
  
  def executor?(user)
    executor == user
  end
  
  # 完成并确认？
  alias :finished? :confirmed?

  def set_file(_file)
    if _file.is_a?(Attachment::File)
      _file.update_attributes(:target => self)
    else
      open(_file.path) do |file|
        _file = Attachment::File.create!(
          :file => file,
          :uploader => _file.uploader,
          :name => _file.name
        )
      end
    end
    self.file = _file
  end

  def set_picture(_picture)
    _picture.update_attributes(:target => self)
    self.picture = _picture
  end

  class << self
    def find_by_id(id)
      where(:_id => id).first
    end

    def find_by_executor_id(executor_id)
      where(:executor_id => executor_id)
    end

    def find_by_creator_id(creator_id)
      where(:creator_id => creator_id)
    end

    def find_by_end_at_lt(date)
      Todo::Task.where(:end_at.lt => date)
    end
  end # /class << self
  
  include Todo::ScheduleObserver
  include Todo::CounterObserver
end
