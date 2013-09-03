# encoding: utf-8
# 工作组

class Admin::GroupsController < Admin::BaseController
  def home
  end

  def index
    @groups = Group.desc("created_at")
    @groups = @groups.where(:pinyin_index => "!") if params[:ch] == "!"
    @groups = @groups.where(:pinyin_index => params[:ch].downcase) if ("A" .. "Z").include?(params[:ch])
    @groups = @groups.paginate :page => params[:page], :per_page => 20
  end
  
  def search
    @groups = Group.desc("created_at")
    unless params[:key].blank?
      reg = /#{params[:key]}/i
        @groups = @groups.where("$or"=>[{:name => reg },{:summary => reg }])
    end
    @groups = @groups.paginate :page => params[:page], :per_page => 20
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new params[:group]
    @group.creator = current_user
    if @group.save
      redirect_to :action=>"index"
    else
      render :action=>"new"
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    @group.update_attributes(params[:group])
    redirect_to :action => "show"
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to :action => "index"
  end
end
