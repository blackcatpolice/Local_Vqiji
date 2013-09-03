# encoding: utf-8

class Talk::MessagesController < Talk::BaseController
  def index
    @feeds = talk_session.feeds.includes(:message)
                         .paginate(page: params[:page], per_page: 10)
    respond_to do |format|
      format.json
    end
    
    talk_session.read(@feeds)
  end
  
  def _create
    @feed = current_user.talk.to(talk_session, params[:text], params)
  end
  
  def create
    _create
    respond_to do |format|
      format.json { render 'talk/feeds/_feed', locals: { feed: @feed } }
    end
  end
  
  def rt_create
    _create
    respond_to do |format|
      format.json { render 'talk/feeds/_rt_feed', locals: { feed: @feed } }
    end
  end
  
  def show
    @feed = talk_feeds.find(params[:id])
    
    respond_to do |format|
      format.json { render 'talk/feeds/_feed', locals: { feed: @feed } }
    end
  end
  
  def destroy
    @feed = talk_feeds.find(params[:id])
    @feed.destroy
    
    respond_to do |format|
      format.json { render json: @feed.to_json( only: [:id] ) }
    end
  end
  
  def unreads
    # FIXME：多个浏览器同时登录一个帐号时，只有一个帐号能收到消息
    # FIXED: 改用 last-response-at 的方式替换 unreads 过滤
    @feeds = talk_session.feeds
      .where(:created_at.gt => Time.at(request.headers['last-response-at'].to_i))
      .includes(:message)
      .paginate(page: params[:page], per_page: 5)

    response.headers['response-at'] = Time.now.to_i.to_s
    talk_session.reset_unread_count! if (params[:reset_unread_count] == 'true')
  end
  
  def unread_count
    respond_to do |format|
      format.json {
        render json: { :unread_count => talk_session.unread_count }
      }
    end
  end
  
  def reset_unread_count
    (@session = talk_session).reset_unread_count!
    render :json => true
  end
  
  # 创建发送私信的弹出窗
  def new_modal_to_user
    @receiver = User.find_by_id(params[:user_id])
    raise Talk::Error, '用户不存在' unless @receiver
    
    render :layout => false
  end
  
  def create_to_user
    receiver = User.find_by_id(params[:user_id])
    raise Talk::Error, '用户不存在' unless receiver
  
    current_user.talk.to_user(receiver, params[:text], params)
    render :json => true
  end
  
  def create_to_user_by_name
    receiver = User.where(:name => params[:name]).first
    raise Talk::Error, '用户不存在' unless receiver
  
    current_user.talk.to_user(receiver, params[:text], params)
    render :json => true
  end
  private

  def talk_session
    @talk_session ||= talk_sessions.find(params[:session_id])
  end
  
  def talk_feeds
    current_user.talk.feeds
  end
end
