# encoding: utf-8

class Talk::SessionsController < Talk::BaseController
  def index
    @sessions = talk_sessions.paginate(page: params[:page], per_page: 10)
    current_user.notification.reset!(Notification::TalkGroupJoin) if (@sessions.current_page == 1)
  end
  
  def create
    unless params[:members].blank?
      users = User.where(:_id.in => params[:members])
    else
      raise Talk::Error, '至少需要一个成员！'
    end
    _group = current_user.talk.create_group(users, params[:topic])
    @session = _group.session_for(current_user)
    respond_to do |format|
      format.json
    end
  end

  def show
    @session = talk_sessions.find(params[:id])
    respond_to do |format|
      format.html {
        @feeds = @session.feeds.includes(:message)
           .paginate(page: params[:page], per_page: 10)
        render
        @session.read(@feeds)
      }
      format.json
    end
  end

  def destroy
    @session = talk_sessions.find(params[:id])
    current_user.talk.quit!(@session.group)
    respond_to do |format|
      format.json { render json: @session }
    end
  end
  
  def pull
    @sessions = talk_sessions.where(:unread_count.gt => 0)
    respond_to do |format|
      format.json
    end
    @sessions.each &:reset_unread_count!
  end
  
  def fetch
    @sessions = talk_sessions
    respond_to do |format|
      format.json
    end
  end
  
  def make_current
    @session = talk_sessions.find(params[:id])
    Talk::Realtime.set_current_session(current_user, @session)
    render :json => true
  end
  
  def clear_current
    Talk::Realtime.clear_current_session(current_user)
    render :json => true
  end
end
