## encoding: utf-8
## 工作组成员
##
class Admin::GroupMembersController < Admin::BaseController


	def index
		@members = @group.members.paginate(:page => params[:page], :per_page => 20)
	end

	def show

	end

	def new
		@members = GroupMember.where(:group_id => @group.id)
	end

	def save
		@group.joins params[:users]	
		redirect_to :action=>"index"
	end

	def set_admin
		@group_member = GroupMember.find(params[:id])
		@group_member.is_admin = true
		@group_member.save
		redirect_to :action => "index"
	end

	#
	def cancel_admin
		@group_member = GroupMember.find(params[:id])
		@group_member.is_admin = false
		@group_member.save
		redirect_to :action => "index"
	end



	def destroy
		@group_member = GroupMember.find(params[:id])
		@group_member.destroy unless @group_member.user.id == @group.creator.id

		redirect_to :action => "index"
	end

	#
	before_filter :require_group
	private
	def require_group
		@group = Group.find(params[:group_id])
	end

end
