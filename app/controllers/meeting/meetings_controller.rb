# encoding: utf-8

# 工作组
class Meeting::MeetingsController < WeiboController

  def recently
    @nav_on_recently = "on"
    @meeting_members = Meeting::MeetingMember.where(:user => current_user).includes(:meeting).order_by(:start_date.asc).paginate(:page => params[:page], :per_page => 10)
    render :index
  end

  def launched
    @nav_on_launched = "on"
    @meeting_members = Meeting::MeetingMember.where(:user => current_user, :is_creator => true).includes(:meeting).order_by(:start_date.asc).paginate(:page => params[:page], :per_page => 10)
    render :index
  end

  def invited
    @nav_on_invited = "on"
    @meeting_members = Meeting::MeetingMember.where(:user => current_user, :is_creator => false).includes(:meeting).order_by(:start_date.asc).paginate(:page => params[:page], :per_page => 10)
    current_user.notification.reset!(Notification::MeetingInvite)
    render :index
  end

  def index
    @meetings = Meeting::Meeting.all.paginate :page => params[:page], :per_page => 10
  end

  def list
    @groups = Group.desc(:created_at)
    unless params[:key].blank?
      @groups = @groups.where("$or"=>[{:name => /#{params[:key]}/i }])
    end
    @groups = @groups.paginate :page => params[:page], :per_page => 8
  end

  def new
    @meeting = Meeting::Meeting.new
  end

  def create
    @meeting = Meeting::Meeting.new(params[:meeting_meeting])
    @meeting.creator = current_user
    @meeting.save
    # redirect_to group_path(@group)
    redirect_to :action => :index
  end

  def show
    @group = Group.find(params[:id])
    @member = @group.members.where(:user_id => current_user.id).first

    if @member
      @feeds = @group.feeds.includes(:group, :tweet, :_sender)
        .paginate(:page => params[:page], :per_page => 20)
    else
      redirect_to :action => :mine
    end
  end

  def tops
    @group = Group.find(params[:id])
    @member = @group.members.where(:user_id => current_user.id).first
    if @member
      @feeds = @group.feeds.includes(:group, :tweet, :_sender).is_top
        .paginate(:page => params[:page], :per_page => 20)      
      render 'groups/show'
      
      # 清除未读重要微博通知
      current_user.notification.delete!(Notification::TopTweet.for(current_user, @group)) if(@feeds.current_page == 1)
    else
      redirect_to :action => :mine
    end
  end

  def edit
    @meeting = Meeting::Meeting.find(params[:id])
  end

  def update
    @group = Group.find(params[:id]);
    @group.update_attributes(params[:group])
    redirect_to group_path(@group)
  end

  def mine
    @group_members = current_user.group_members.desc(:created_at)

    respond_to do |format|
      format.html {
        @group_members = @group_members
          .paginate(:page => params[:page], :per_page => 8)
        
        # 清除新加入组通知
        current_user.notification.reset!(Notification::GroupJoin) if(@group_members.current_page == 1)
      }
      format.json
    end
  end

  def gets
    @groups = Group.all
    respond_to do |format|
      format.html
      format.json
    end
  end

  def select
    @groups = Group.all
    render :json => @groups.all.to_json(:only => [:_id, :name])
  end
end
