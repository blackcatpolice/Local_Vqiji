# encoding: utf-8
# 工作组成员
#
class Meeting::MeetingMembersController < WeiboController

  before_filter :set_meeting, :except => :change_status
  # before_filter :should_be_admin, :except => :index
  
  private
  
  def set_meeting
    @meeting = Meeting::Meeting.find(params[:meeting_id])
  end
  
  def should_be_admin
    unless @group.has_admin?(current_user)
      # raise WeiboError, '亲，这儿不是您该来的地方～'
      redirect_to mine_groups_path
    end
  end
  
  public

  def change_status
    @meeting_member = Meeting::MeetingMember.find(params[:meeting_id])
    @meeting_member.update_attribute(:participate_status, params[:participate_status])
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

  def index
    @members = @meeting.members.attending_meeting(params[:status]).includes(:user)
      .desc([:is_admin, :created_at])
      .paginate :page => params[:page], :per_page => 10
    @members = @meeting.members
    render :new
  end

  def list
    @members = @meeting.members.attending_meeting(params[:status]).includes(:user)
      .desc([:is_admin, :created_at])
      .paginate :page => params[:page], :per_page => 10
  end

  def new
    @members = @meeting.members
  end

  def set_admin
    @group_member = @group.members.find(params[:id])
    @group.set_admin(@group_member.user)
    redirect_to :action => :list
  end

  def cancel_admin
    @group_member = @group.members.find(params[:id])
    @group.cancel_admin(@group_member.user)
    redirect_to :action => :list
  end

  # 退出
  def quit
    @group_member = @group.members.find(params[:id])
    if @group_member && @group.quitable # 确保可以退出
      if (@group.members_count <= 1) # 最后一个用户，退出后删除小组
        @group.remove_member!(@group_member.user)
      else
        if (@group_member.is_admin && (@group.admins_count > 1))
          @group.remove_member!(@group_member.user)
        else
          flash['notice'] = '退出小组失败, 小组中管理员数量至少2个才能退出小组.'
        end
      end
    end
    redirect_to mine_groups_path
  end

  def save
    unless params[:users].blank?
      user_ids = User.where(:_id.in => params[:users]).distinct(:id)
      @meeting.invite_users(user_ids) if user_ids.any?
    end
    redirect_to :action => :list
  end

  def delete
    group_member = @group.members.find(params[:id])
    if group_member
      @group.remove_member!(group_member.user)
    end
    redirect_to :action => :list, :group_id => params[:group_id], :page => params[:page]
  end
end
