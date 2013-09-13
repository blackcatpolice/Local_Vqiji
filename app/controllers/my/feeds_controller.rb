# encoding: utf-8

# 当前用户收到的微博
class My::FeedsController < WeiboController

  # 获取收到的微博列表
  #
  # == 参数：
  #  [分页]
  #
  def index
    @feeds = current_user.feeds
      .paginate(:page => params[:page], :per_page => 20)

    set_feeds_timeline if @feeds.current_page == 1
  end

  # 获取新收到的微博列表
  #
  def news
    @feeds = new_feeds.paginate(:page => 1, :per_page => 20 * 3) #

    set_feeds_timeline if @feeds.current_page == 1
  end
end
