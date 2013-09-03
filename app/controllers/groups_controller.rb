# encoding: utf-8

# 工作组
class GroupsController < WeiboController

	def index
		@groups = current_user.groups
		respond_to do |format|
		  format.json
		end
	end

	def list
	  @groups = Group.desc(:created_at)
    unless params[:key].blank?
      @groups = @groups.where("$or"=>[{:name => /#{params[:key]}/i }])
    end
    @groups = @groups.paginate :page => params[:page], :per_page => 8
	end

	def new
		@group = Group.new
	end

	def create
		@group = Group.new(params[:group])
		@group.creator = current_user
		@group.quitable = true
		@group.save
		redirect_to group_path(@group)
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
		@group = Group.find(params[:id])
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
