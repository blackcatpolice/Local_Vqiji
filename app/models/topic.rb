# encoding: utf-8
#

#
# 话题
#
class Topic
  include Mongoid::Document
  
  TITLE_MINLEN = 1
  TITLE_MAXLEN = 32
  
  
  # 标题
  field :title

  # Mongoid 3.0 support attr_readonly
  # attr_readonly :title
  
  validates_presence_of   :title
  validates_length_of     :title, :in => TITLE_MINLEN..TITLE_MAXLEN
  validates_uniqueness_of :title
  
  def as_json(options = nil)
    {
      :title => title
    }
  end

  public
  
  # 提到该话题的微博
  def tweets
    Tweet.reference_topic(title)
  end
  
  #大厅微博
  def hall_tweets
    tweets.where(:group_ids => nil)
  end
  
  #工作组微博
  def group_tweets
    tweets.where(:group_ids.ne => nil)
  end
  
  def self.find_by_title(title)
    where(:title => title).first
  end
end
