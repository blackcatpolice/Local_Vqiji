# encoding: utf-8

# 微博收藏
class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :user,  class_name: 'User', inverse_of: :favorites, counter_cache: true
  belongs_to :tweet, class_name: 'Tweet', inverse_of: :favorites, counter_cache: true
  
  validates_presence_of :user, :tweet
  validates_uniqueness_of :tweet, scope: :user

  # 默认排序
  default_scope desc(:created_at)

  class Error < WeiboError; end
  
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
    def favorite(tweet)
      if !favorite?(tweet)
        @user.favorites.create!(tweet: tweet)
      end
    end
    
    # 取消收藏
    def unfavorite!(tweet)
      @user.favorites.where(tweet_id: tweet.to_param).destroy
    end
  end # /Service
  
  module UserExtends
    def self.included(base)
      base.class_eval do
        has_many :favorites, inverse_of: :user, dependent: :destroy, autosave: true
        field :favorites_count, :type => Integer, :default => 0 # 收藏数量

        def favorite_service
          @_favorite_service_ ||= Favorite::Service.new(self)
        end

        delegate :favorite?, :favorite, :unfavorite!, :to => :favorite_service
      end
    end
  end # /UserExtends
end
