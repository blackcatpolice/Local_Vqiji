# encoding: utf-8
# 统计每个用户相关的任务
class Todo::Count
	include Mongoid::Document
	
	
	####  分配的任务
	field :create, :type => Integer, :default => 0             # 总任务
	field :create_now, :type => Integer ,:default => 0         # 进行中任务数
	field :create_completed_ontime,:type => Integer ,:default => 0     # 按时完成任务
	field :create_completed_timeout, :type => Integer, :default => 0     #被超时完成任务数
	#
	
	####  收到的任务
	field :execute, :type => Integer , :default => 0           # 总任务
	field :execute_now, :type => Integer ,:default => 0        # 进行中任务数
	field :execute_completed_ontime,:type => Integer, :default => 0    # 已完成任务数 
	field :execute_completed_timeout, :type => Integer, :default => 0    # 超时完成任务数 
	
	
	# relations
	belongs_to :user, :class_name => 'User'

	# validates
	validates :user_id, uniqueness: true, allow_nil: false

	def reject
		
	end

	# class methods
	def self.find_by_id id
		where(:_id => id).first
	end

	def self.find_by_user_id user_id
		where(:user_id => user_id).first
	end
	
	before_create do |count|
		count.id = self.user.id
	end
end
