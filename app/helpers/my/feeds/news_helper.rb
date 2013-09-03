# encoding: utf-8

module My::Feeds
  # 该 helper 主要控制新微博数统计
  module NewsHelper
    # 设置当前用户微博显示当前时间线
    def set_feeds_timeline(time = Time.now)
      session[:feeds_timeline] = time
    end
    
    # feeds 时间线
    def feeds_timeline
      session[:feeds_timeline]
    end
    
    # 获取当前用户收到的新微博
    def new_feeds
      current_user.feeds
        .after(feeds_timeline)
        .where(:sender_id.ne => current_user.id.to_s)
    end
    
    # 新 feeds 数
    def new_feeds_count
      new_feeds.count
    end
  end # /NewsHelper
end
