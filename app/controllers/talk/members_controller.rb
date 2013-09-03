class Talk::MembersController < Talk::BaseController
  before_filter :set_session, only: [:index, :add, :destroy]
  
  def index
    @members = @session.group.sessions.includes(:user, :group)
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def add
    unless params[:members].blank?
      users = User.where(:_id.in => params[:members])
      current_user.talk.add_members(@session.group, users)
    end
    respond_to do |format|
      format.json { render json: @session }
    end
  end
  
  def destroy
    current_user.talk.delete_member!(@session.group, params[:id])
    respond_to do |format|
      format.json { render :json => true }
    end
  end
  
  protected
  
  def set_session
    @session ||= talk_sessions.find(params[:session_id])
  end
end
