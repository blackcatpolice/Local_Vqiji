# encoding: utf-8
class UsersController < WeiboController
  # 显示用户主页
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.json { render :json => @user.as_json }
      format.html {
        # 如果该用户是当前用户，显示当前用户的主页
        @tweets = @user.tweets
        @tweets = @tweets.to_fans if(current_user != @user)
        @tweets = @tweets.paginate(:page => params[:page], :per_page => 10)
      }
    end
  end
  
  # 关注的人
  def followeds
    @user = User.find(params[:id])
    @ships = @user.followships
    @ships = @ships.except_whisper unless current_user.id == @user.id
    @ships = @ships.desc(:created_at)
      .paginate(:page => params[:page], :per_page => 10)
  end

  # 粉丝
  def fans
    @user = User.find(params[:id])
    @ships = @user.fanships.except_whisper
      .paginate(:page => params[:page], :per_page => 10)
    
    render
    # 清除新粉丝通知
    current_user.notification.reset!(Notification::Fan) if (@user == current_user)
  end

  def search
    _query = params[:q].blank? ? User.all : User.fuzzy_search_by_name(params[:q])

    respond_to do |format|
      format.html {
        @users = _query.desc(:created_at)
          .paginate(:page => params[:page], :per_page => 20)
      }
      format.json {
        @users = _query.desc(:created_at).only(:_id, :name).limit(3)
        render :json => @users.to_json(:methods => :id, :only => :name)
      }
    end
  end
  
  def card
    @user = User.find(params[:id])
    respond_to do |format|
      format.json
    end
  end
end
