# encoding: utf-8
#e-Training
# 培训
class Training
  include Mongoid::Document
  include Mongoid::Timestamps

  #
  belongs_to :user,:class_name => 'User' # 发布用户
  belongs_to :type,:class_name => 'TrainingType'  #培训类型

  has_many :pages, :class_name => 'TrainingPage', :dependent => :destroy #培训页
  has_many :users, :class_name => 'TrainingUser', :dependent => :destroy #参与培训的用户
  has_many :tests, :class_name => 'TrainingTest', :dependent => :destroy #培训测试

  field :name,:type => String # 培训名称
  field :pages_count,:type => Integer,:default => 0 #培训页数量
  field :users_count,:type => Integer,:default => 0 #参与用户数量
  field :tests_count,:type => Integer,:default => 0 #测试题目数量
  field :summary,:type => String # 培训简介
  field :context,:type=> String #培训内容
  field :ids,:type => Array # 参与培训的用户ID
  field :begin_date,:type => Date,:default => Time.now #开始时间，默认当前时间
  field :end_date,:type => Date,:default => Time.now.ago(-30.days) #兑换截止时间,默认30天以后
  field :pass_score,:type => Integer,:default => 60 #培训通过的分数
  field :released,:type => Boolean,:default => false #培训是否发布
  field :user_ids,:type => Array,:default => Array.new #参与培训的用户ID
  #field :error,type:String

  def set_users(user_ids)
    return if self.released # 培训发布后不能添加用户
    user_ids = user_ids.uniq
    exists_ids = users.distinct(:user_id).collect(&:to_s)
    TrainingUser.where(:training_id => self.id, :user_id.in => (exists_ids - user_ids)).destroy_all
    User.where(:_id.in => (user_ids - exists_ids)).each do |user|
      TrainingUser.create(:user => user, :training_id => self.id)
    end
  end

  #取消发布
  def cancel
    self.update_attributes(:released=>false)
    self.users.update_all(:released=>false)
  #self.users.destroy_all
  end

  #发布培训
  def release?
    self.errors.add("内容页数为0","请创建培训内容页") if self.pages_count == 0
    self.errors.add("参与用户为0","请指定参与培训的用户") if self.users_count == 0

    return false if self.errors.any?
    #return if self.released
    self.update_attributes(:released=>true) #修改培训状态
    self.users.update_all(:released=>true) #修改培训用户状态
    #发送通知
    #self.users.each do |tu|
    #  Unreads.inc!(tu.user_id, 'trainings', 1)
    #end
    return true
  end

  def create_page options
    page =  TrainingPage.new(options)
    page.training_id = self.id
    page.save
  end

  #培训是否超时
  def timeout
    return (Time.now>self.end_date.ago(-1.days))
  end

  def days7
    return true if Time.now.ago(-7.days) >= self.end_date
    return false
  end

  #还有天数
  def also_days
    (DateTime.parse(self.end_date.strftime("%Y-%m-%d")) - DateTime.parse(Time.now.strftime("%Y-%m-%d"))).to_i
  end
  
  class << self
    def find_by_id(id)
      where(_id: id).first
    end

    def get_ids(&block)
      trainings = (block ? block.call(trainings) : all)
      trainings ? [] : trainings.distinct(:_id)
    end
  end

  private

  #
  after_create :increase_counter_cache

  def increase_counter_cache
    self.type.inc(:trainings_count,1)
  end

  after_update do
    unless self.released
      destroy_sys_todos
    else
      create_or_update_sys_todo
    end
  end

  #
  after_destroy :decrease_conuter_cache, :destroy_sys_todos

  def decrease_conuter_cache
    return if self.type.trainings_count <= 0
    self.type.inc(:trainings_count,-1)
  end

  def destroy_sys_todos
    Schedule::SysTodo.trainings.where(:target_id => self.id,:scope => Schedule::SysTodo::SCOPE_TRAINING).destroy
  end

  def create_or_update_sys_todo
    self.user_ids.each do |u|
      sys_todo = Schedule::SysTodo.trainings.where(:target_id => self.id, :user_id => u).first
      unless sys_todo.blank?
        unless sys_todo.at.to_i == self.end_date.end_of_day.to_i
        sys_todo.at = self.end_date.end_of_day
        sys_todo.save
        end
      else
        Schedule::SysTodo.create(
          :detail => self.name,
          :at => self.end_date.end_of_day,
          :user_id => u,
          :target_id => self.id,
          :target_url => "/elearn/trainings/#{self.id}",
          :scope => Schedule::SysTodo::SCOPE_TRAINING
        )
      end
    end
  end

end
