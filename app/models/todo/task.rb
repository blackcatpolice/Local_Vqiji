# encoding: utf-8

# 任务
class Todo::Task
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  LS = { "0" => "普通", "1" => "重要", "2" => "紧急" }
  SS = { "1" => "进行到", "2" => "待确认", "3" => "已完成"}

  SCHEDULE_ING = 1      #任务 进行中
  SCHEDULE_CONFIRM = 2  #任务 待确认
  SCHEDULE_COMPLETED = 3 #任务 已完成

  # fields
  field :title, :type => String # 标题
  field :level, :type => Integer, :default => 0 # 优先级 0 => 普通 ，1 => 重要， 2 => 紧急

  field :details, :type => String # 详细
  field :start_date, :type => Time # 开始日期
  field :end_date, :type => Time  # 结束日期

  field :value, :type => Integer, :default => 0 # 进度=> 0%-100%
  field :subs_count, :type => Integer ,:default => 0 # 子任务数量
  field :executor_name, :type => String #执行者 姓名
  field :schedule, :type => Integer, :default => SCHEDULE_ING #  任务进度  1 => 进行中, 2 => 待确认, 3 => 完成 
  
  field :confirm_at, :type => Time  #确认时间, 任务进度改为100％的修改时间
  field :completed_at, :type => Time  #完成时间
  field :is_new, :type => Boolean, :default => true  #是否是新任务
  
  field :time_out, :type => Boolean, :default => false

  embeds_one :file, class_name: 'Attachment::File' #文件
  embeds_one :picture, class_name: 'Attachment::Picture' #图片
  
  # relations
  belongs_to :creator, :class_name => 'User', inverse_of: :created_todo_tasks # 任务创建人
  belongs_to :executor,:class_name => 'User', inverse_of: :todo_tasks # 任务执行者
  belongs_to :sup, :class_name => 'Todo::Task', inverse_of: 'subs' # 父任务
  has_many :subs, :class_name => 'Todo::Task', inverse_of: :sup # 子任务
  has_many :logs, :class_name => 'Todo::Log', inverse_of: :task, :dependent => :destroy, autosave: true
  
  # validates
  validates :title, presence: true

  #before_create do |task|
    #task.created = true
  #end

  # index
  index :executor_id => 1
  index :creator_id => 1

  # 默认排序 使用时间倒序排序
  #default_scope desc(:created_at)
  scope :confirm_scope, where(:schedule => SCHEDULE_CONFIRM)
  scope :finished_scope, where(:schedule => SCHEDULE_COMPLETED)
  scope :unfinished_scope, where(:schedule.ne => SCHEDULE_COMPLETED)
  scope :value_hundred_scope, where(:value => 100)
  scope :value_lte_hundred_scope,where(:value.lte => 100)
  scope :executor_scope, ->(executor_id) { where(:executor_id => executor_id) }
  scope :executor_unfinished_scope, ->(executor_id) { executor_scope(executor_id).unfinished_scope}
  scope :timeout_scope, where(:end_date.lte => Time.now)

  before_save do
    unless self.schedule == SCHEDULE_COMPLETED
      self.schedule = self.value == 100 ? SCHEDULE_CONFIRM : SCHEDULE_ING
      self.confirm_at = Time.now if self.schedule == SCHEDULE_CONFIRM
    else
      self.time_out = true if self.confirm_at > self.end_date
    end
  end
  
  after_destroy do
    Schedule::SysTodo.where(:target_id => self.id, :scope => Schedule::SysTodo::SCOPE_TODO_TASK).destroy
  end
  
  after_create :create_sys_todo
  
  after_update do
    systodo = Schedule::SysTodo.todo_tasks.where(:target_id => self.id, :scope => Schedule::SysTodo::SCOPE_TODO_TASK).first
    unless systodo.blank?
      unless systodo.at.to_i == self.end_date.to_i
        systodo.at = self.end_date
        systodo.save
      end
    else
      self.create_sys_todo
    end
  end

  def create_sys_todo
    Schedule::SysTodo.create(
      :detail => self.title,
      :at => self.end_date,
      :user_id => self.executor_id,
      :target_id => self.id,
      :target_url => "/todo/tasks/#{self.id}", 
      :scope => Schedule::SysTodo::SCOPE_TODO_TASK
    )
  end

  def task_danger
    self.end_date <= Time.now.ago(-3.days)
  end

  # instance methods
  def is_timeout
    (Time.now > self.end_date)
  end
  
  def timeout_format
    seconds = Time.now - self.end_date
    days = seconds/ (3600 * 24)
    unless days.abs < 1
      return (days > 0 ? "已经超时#{days.to_i}天" : "还有#{days.abs.to_i}天到期")
    end
    hours = seconds/3600
    unless hours.abs < 1
      return (hours > 0 ? "已经超时#{hours.to_i}小时" : "还有#{hours.abs.to_i}小时到期")
    end
    minutes = seconds/60
    return (seconds > 0 ? "已经超时1分钟" : "还有1分钟到期") if seconds.abs < 60
    unless seconds.abs < 1
      return (minutes > 0 ? "已经超时#{minutes.to_i}分钟" : "还有#{minutes.abs.to_i}分钟到期")
    end
  end

  def set_file(_file)
    unless _file.is_a?(Attachment::File)
      open(_file.path) do |file|
        _file = Attachment::File.create!({
          :file => file,
          :uploader => _file.uploader,
          :name => _file.name
        })
      end
    else
      _file.update_attributes(:target => self)
    end
    self.file = _file
  end

  def set_picture(_picture)
    _picture.update_attributes(:target => self)
    self.picture = _picture
  end

  def to_tree_node(opts = {})
    children = []
    unless self.subs.blank?
      self.subs.each do |t|
        tree_node = Todo::TreeNode.new(:id => t.id, :text => t.title) 
        tree_node.creator =  t.creator.name
        tree_node.executor =  t.executor.name
        if t.subs.count > 0
          tree_node.has_children = true
          tree_node.expanded = false
        end
        children << tree_node 
      end
    end
    Todo::TreeNode.new( :id => self.id, :text => self.title, :children => children, :classes => opts[:classes], :creator => self.creator.name, :executor => self.executor.name) 
  end

  # class methods
  class << self
    def find_by_id id
      where(:_id => id).first
    end

    def find_by_executor_id executor_id
      where(:executor_id => executor_id)
    end

    def find_by_creator_id creator_id
      where(:creator_id => creator_id)
    end

    def find_by_end_date_lt date
     Todo::Task.where(:end_date => {'$lt' => date})
    end

    def find_will_timeout executor_id
      date =  Time.now.ago(-3.days)
      unfinished_scope.where(:executor_id => executor_id).where(:end_date.gte => Time.now).where(:end_date.lte => date)
    end
    
    #column => creator_id || executor_id
    def find_timeout_count column, user_id
      where("#{column}" => user_id).timeout_scope.count
    end
  end

end
