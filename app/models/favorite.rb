# encoding: utf-8

# 微博收藏
class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Taggable
  
  # 使用空格分割
  tags_separator /\s/

  belongs_to :user,  class_name: 'User', inverse_of: :favorites, counter_cache: true
  belongs_to :tweet, class_name: 'Tweet', inverse_of: :favorites, counter_cache: true
  
  validates_presence_of :user, :tweet
  validates_uniqueness_of :tweet, scope: :user

  # 默认排序
  default_scope desc(:created_at)
  
  index :user_id => 1
  index :tweet_id => 1
  index({ :user_id => 1, :tweet_id => 1 }, :unique => true)
  
  scope :untagged, -> { where(:'$or' => [ { :tags_array => [] }, { :tags_array => nil } ]) }
  
  around_save do |favorite, block|
    unless favorite.tags_array_changed?
      block.call
    else
      block.call
      user = favorite.user
      new_tags = tags_array - user.favorite_service.tags
      new_tags.each do |tag|
        user.favorite_tags.create(:tag => tag)
      end
    end
  end

  class Error < WeiboError; end
  
  class Tag
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    belongs_to :user, class_name: 'User', inverse_of: :favorite_tags
    field :tag
    
    validates_presence_of :user, :tag
    validates_uniqueness_of :tag, scope: :user
    
    def favorites
      @user.favorites.where(:tags_array => [tag])
    end
  end
  
  class Service
    attr_reader :user
    
    def initialize(user)
      @user = user
    end
    
    # 是否收藏微博
    def favorite?(tweet)
      @user.favorites.where(tweet_id: tweet.to_param).exists?
    end
    
    # 收藏微博
    def favorite(tweet, tags = nil)
      if !(_favorite = of(tweet))
        _favorite = @user.favorites.create!(tweet: tweet, tags: tags)
      end
      _favorite
    end
    
    # 取消收藏
    def unfavorite!(tweet)
      @user.favorites.where(tweet_id: tweet.to_param).destroy
    end
    
    def set_tags!(favorite, tags)
      favorite.tags = tags
      favorite.save!
    end
    
    def tags
      @user.favorite_tags.distinct(:tag)
    end
    
    def of(tweet)
      @user.favorites.where(tweet_id: tweet.to_param).first
    end
  end # /Service
  
  module UserExtends
    def self.included(base)
      base.class_eval do
        has_many :favorites, inverse_of: :user, dependent: :destroy, autosave: true
        field :favorites_count, :type => Integer, :default => 0 # 收藏数量
        
        has_many :favorite_tags, class_name: 'Favorite::Tag', inverse_of: :user, dependent: :destroy, autosave: true

        def favorite_service
          @_favorite_service_ ||= Favorite::Service.new(self)
        end

        delegate :favorite?, :favorite, :unfavorite!, :to => :favorite_service
      end
    end
  end # /UserExtends
end
