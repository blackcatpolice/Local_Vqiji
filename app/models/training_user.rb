# encoding: utf-8

# 培训参与者
class TrainingUser
  include Mongoid::Document
  include Mongoid::Timestamps

  #fields
  belongs_to :training, :class_name => 'Training' #参与的培训
  belongs_to :user, :class_name => 'User' #参与培训的用户
  
  belongs_to :page, :class_name => 'TrainingPage' #培训页
  field :page_no, type: Integer, default: 0 #页码
  field :page_id, type: String #当前 Page ID
  field :score, type: Integer, default: 0 #考试分数
  field :name, type: String # 培训名称
  field :released, type: Boolean, default: false #培训是否发布

  # 状态
  field :start, type: Boolean, default: false #已经开始
  field :finished, type: Boolean, default: false #是否完成
  field :exam, type: Boolean, default: false #是否考试
  field :check, type: Boolean, default: false #是否评分
  field :pass, type: Boolean, default: false #是否通过
  field :qas, type: Hash, default: {}  #问题与答案, key => 题目ID ，value => 用户答案
  field :score_hash, type: Hash, default: {} #得分情况 key => 题目ID ，value => 得分
  field :pages, :type => Array, :default => [] #
  
  # scopes
  scope :user_scope, lambda{|user_id|where(:released=>true,:user_id => user_id)}

  scope :pass_scope, lambda{|user_id|where(:user_id => user_id,:pass=>true,:released=>true)}
  scope :unpass_scope, lambda{|user_id|where(:user_id => user_id,:pass=>false,:released=>true)}
  scope :finished_scope, lambda{|user_id|where(:user_id=>user_id,:finished=>true)}
  scope :training_scope, lambda{|training_id|where(:training_id => training_id)}
  scope :get_scope, lambda{|user_id,training_id|where(:user_id => user_id,:training_id => training_id)}
  #
  scope :timeout_scope, lambda{|user_id| includes(:training).user_scope(user_id).where(:'training.end_date'.gt => Time.now)}

  #根据用户ID 和 培训ID 得到 相应用户的培训信息
  def self.get(user_id, training_id)
    get_scope(user_id,training_id).first
  end

  def reset
    self.update_attributes(:start=>false,:pass=>false,:finished=>false,:exam=>false,:check=>false)
    self.update_attributes(:page_id=>nil,:pages=>Array.new,:score=>0,:qas=>Hash.new,:score_hash=>Hash.new)
    self.save
  end
  
  #当前状态
  def status
    return "已通过 #{self.score}分" if self.pass
    return "未开始" unless self.start
    return "未完成" unless self.finished
    return "未考试" unless self.exam
    return "未评分" unless self.check
    return "未通过 #{self.score}分" unless self.pass
  end

  #
  before_save :update_status

  def update_status
    self.start = true if self.pages.length == 1
    self.finished = true if self.pages.length == self.training.pages_count
  end
  
  #
  after_create :increase_counter_cache

  def increase_counter_cache
    self.training.inc(:users_count,1) if self.training
  end
  
  #
  after_destroy :decrease_counter_cache, :destroy_sys_todo
  
  def decrease_counter_cache
    self.training.inc(:users_count,-1) if self.training && self.training.users_count > 0 
  end
  
  def destroy_sys_todo
    Schedule::SysTodo.trainings.where(:target_id => self.training_id, :user_id => self.user_id).destroy_all
  end
end
