# encoding: utf-8

# 任务日志
class Todo::Log
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  field :info, :type => String # 日志信息
  field :msg, :type => String # 日志消息
  field :sequence, :type => Integer # 日志序列
  field :old_value, :type => Integer, :default => 0 #shang
  field :value, :type => Integer,:default => 0  # 任务进度 百分比 [0-100]
  field :old_task_schedule, :type => Integer, :default => Todo::Task::SCHEDULE_ING
  field :task_schedule, :type => Integer, :default => Todo::Task::SCHEDULE_ING
  
  embeds_one :file, class_name: 'Attachment::File', cascade_callbacks: true  #文件
  embeds_one :picture,  class_name: 'Attachment::Picture'  #图片
  
  belongs_to :task, :class_name => 'Todo::Task', inverse_of: :logs
  belongs_to :sub, :class_name => 'Todo::Task', inverse_of: :sup
  belongs_to :user, :class_name => 'User'

  default_scope desc(:created_at)
  
  before_save do 
    self.task_schedule = self.task.schedule
    
    unless self.task_schedule == self.old_task_schedule
      creator_count = Todo::Count.find_by_user_id(task.creator_id)
      executor_count = Todo::Count.find_by_user_id(task.executor_id)
      
      case self.task_schedule
        when Todo::Task::SCHEDULE_ING
          if self.old_task_schedule == Todo::Task::SCHEDULE_CONFIRM
            creator_count.inc(:create_confirm, -1) if creator_count.create_confirm > 0
            executor_count.inc(:execute_confirm, -1) if executor_count.execute_confirm > 0
          end
          
          creator_count.inc(:create_now, 1)
          executor_count.inc(:execute_now, 1)
          
        when Todo::Task::SCHEDULE_CONFIRM
          
          creator_count.inc(:create_now, -1) if creator_count.create_now > 0
          executor_count.inc(:execute_now, -1) if executor_count.execute_now > 0
          
          creator_count.inc(:create_confirm, 1)
          executor_count.inc(:execute_confirm, 1)
          
        when Todo::Task::SCHEDULE_COMPLETED
          if self.old_task_schedule == Todo::Task::SCHEDULE_ING
            creator_count.inc(:create_now, -1) if creator_count.create_now > 0
            executor_count.inc(:execute_now, -1) if executor_count.execute_now > 0
          elsif self.old_task_schedule == Todo::Task::SCHEDULE_CONFIRM
            creator_count.inc(:create_confirm, -1) if creator_count.create_confirm > 0
            executor_count.inc(:execute_confirm, -1) if executor_count.execute_confirm > 0  
          end
          
          task.time_out ? creator_count.inc(:create_completed_timeout, 1) : creator_count.inc(:create_completed_ontime, 1)
          task.time_out ? executor_count.inc(:execute_completed_timeout, 1) : executor_count.inc(:execute_completed_ontime, 1)
      end
    end
  end
  
  def set_file file_id
    return  if file_id.blank?
    _file = Attachment::Base.get(file_id)
    return  if _file.blank?
    _file.target = self
    _file.save
    self.file = _file
  end

  def set_picture picture_id
    return if picture_id.blank?
     _picture = Attachment::Picture.get(picture_id)
     return if _picture.blank?
     _picture.target = self
     _picture.save
     self.picture = _picture
  end
  
end
