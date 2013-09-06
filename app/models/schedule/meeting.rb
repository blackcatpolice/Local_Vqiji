class Schedule::Meeting
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection

  field :detail, :type => String
  field :at, :type => DateTime
  
  belongs_to :user, inverse_of: :schedule_todos
  belongs_to :meeting, :class_name => 'Meeting::Meeting', :inverse_of => :schedule_meeting
  
  # validtions
  # validates :detail, presence: true
  validates :at, presence: true
  validates :user, presence: true
  
  # indexes
  index :user_id => 1, :at => -1
  
  # scopes
  default_scope asc(:at)

  scope :in_range, ->(start_time, end_time) {
    where(:at.gte => start_time, :at.lte => end_time)
  }
  
  def to_builder
    Jbuilder.new do |json|
      json.(self, :id, :detail, :at)
    end
  end
end
