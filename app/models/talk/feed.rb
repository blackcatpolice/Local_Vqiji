# encoding: utf-8

class Talk::Feed
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  belongs_to :message, class_name: 'Talk::Message', inverse_of: :messages
  belongs_to :receiver, class_name: 'User', inverse_of: :talk_feeds
  belongs_to :group, class_name: 'Talk::Group', inverse_of: :feeds
  
  field :is_read, type: Boolean, default: false
  
  # validations
  validates_presence_of :receiver, :group
  validates :message, presence: true, uniqueness: { scope: :receiver_id }
  
  # indexes
  index :receiver_id => 1
  index :created_at => -1
  index :receiver_id => 1, :created_at => -1
  index :receiver_id => 1, :group_id => 1, :created_at => -1
  index({ :receiver_id => 1, :message_id => 1 }, unique: true)
  index :is_read => 1
  
  after_create do |feed|
    feed.session.inc(:unread_count, 1) unless feed.is_read
  end
  
  after_destroy do |feed|
    feed.session.inc(:unread_count, -1) unless feed.is_read
  end
  
  # scopes
  default_scope desc(:created_at)
  scope :of_group, ->(group) { where(group_id: group.to_param) }
  scope :unread, where(:is_read.ne => true)

  def session
    @session ||= Talk::Session.where(user_id: receiver_id, group_id: group_id).first
  end
end
