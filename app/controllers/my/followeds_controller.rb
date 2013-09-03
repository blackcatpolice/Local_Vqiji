# encoding: utf-8

# 关注的人
class My::FollowedsController < WeiboController
  
  # 关注用户
  #
  # == 参数：
  #   * user_id: 被关注的用户 id
  #
  # 返回被关注用户的详细信息
  def create
    @user = User.find(params[:user_id])
    current_user.follow(@user,{follow_type: params[:follow_type]})
    
    @user.reload
    respond_to do |format|
      format.json {
        render '/users/follow_state'
      }
    end
  end
  
  # 取消关注用户
  #
  # == 参数：
  #   * id/user_id: 被关注的用户 id
  #
  # 返回被取消关注用户的详细信息
  def destroy
    @user = User.find(params[:id] || params[:user_id])
    current_user.unfollow!(@user)
    
    @user.reload
    respond_to do |format|
      format.json {
        render '/users/follow_state'
      }
    end
  end

  # 查询我关注的人
  def query
    #@followeds = current_user.followeds
    respond_to do |format|
      format.json {
        render :json => User.fuzzy_search_by_name(params[:query])
                            .paginate(:page => params[:page], :per_page => params[:psize] || 10)
                            .as_json(:only => [:id, :name])
      }
    end
  end
end
