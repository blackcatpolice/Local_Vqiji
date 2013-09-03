# encoding: utf-8

class Department
  include Mongoid::Document
  include Mongoid::Timestamps
  include Handler::PinyinIndex

  TOP_LEVEL = 0 # 大部门
  FIRST_LEVEL= 1 # 一级部门
  SECOND_LEVEL = 2 # 二级部门

  LS = { "0" => "大部门", "1" => "一级部门", "2" => "二级部门"}

  field :name, :type => String
  field :level, :type => Integer, :default => TOP_LEVEL
  belongs_to :creator, :class_name => 'User', inverse_of: nil
  
  has_many :members, class_name: 'User', inverse_of: 'department'
  field :members_count, :type => Integer, :default => 0

  belongs_to :sup, :class_name => 'Department', inverse_of: 'subs' # 父级部门
  has_many :subs, :class_name => 'Department', inverse_of: 'sup' # 子级部门
  
  # helper fields
  field :_full_name
  has_one :_group, :class_name => 'Group', inverse_of: :department

  #
  validate :sup, :present => true, :if => ->(department) { department.second_level? }, :on => :create

  attr_accessible :name, :level, :sup_id
  attr_readonly :name, :level, :sup

  before_create do |department|
    department._full_name = department.full_name
  end

  scope :top_scope, where(:level => 0)
  scope :first_scope, where(:level => 1)
  scope :second_scope, where(:level => 2)

  def full_name
    _full_name || (((level == SECOND_LEVEL) && sup) ? "#{ sup.full_name }-#{ name }" : name)
  end

  # 默认的关联工作组
  def group
    _group || Group.create!(:department => self, :name => full_name, :quitable => false)
  end

  def second_level?
    level == Department::SECOND_LEVEL
  end

  def add_member(user)
    return if user.department == self
    
    if user.department
      remove_member(user)
    end
    members << user
    _after_add_member(user)
  end

  def remove_member(user)
    members.delete user
    _after_remove_member(user)
  end

  private

  def _after_add_member(user)
    group.join(user)
    if second_level?
      sup.group.join(user)
    end
  end
  
  def _after_remove_member(user)
    group.remove_member!(user)
    if second_level?
      sup.group.remove_member!(user)
    end
  end
  
  public

  class << self
    def query(opts)
      query = all
      query.merge!( where(:level => opts[:level]) ) if opts[:level]
      query.merge!( where(:pinyin_index => '!') ) if opts[:ch] == '!'
      query.merge!( where(:pinyin_index => opts[:ch].downcase) ) if ('A' .. 'Z').include?(opts[:ch])
      query
    end

    def find_by_name(name)
      where(:name=>name).first
    end

    alias :get_by_name :find_by_name
  end
end
