# encoding: utf-8
class Knowledge::KnowledgesController < WeiboController
  
  layout proc { |c| pjax_request? ? pjax_layout : 'knowledge' }

  #所有公开的文档
  def index

    # query = Knowledge.search do
    #   fulltext params[:keyword]
    #   with :knowledge_type_id, params[:type] if params[:type]
    #   with :public, true
    #   order_by :created_at, :desc
    #   paginate :page => params[:page], :per_page => (params[:size] || 10)
    # end
    # @knowledges = query.results
    @knowledge_types = Knowledge::KnowledgeType.all.asc(:priority)
    if params[:type] || params[:group_id]
      @knowledge_type = Knowledge::KnowledgeType.find(params[:type]) if params[:type]
      @knowledges = Knowledge::Knowledge.published
      @knowledges = params[:group_id].nil? ? @knowledges.public : @knowledges.where(:group_id => params[:group_id])
      # @knowledges = @knowledges.where(:group_id => params[:group_id]) if params[:group_id]
      @knowledges = @knowledges.where(:knowledge_type_id => params[:type]) if params[:type]
      @knowledges = @knowledges.paginate(:page => params[:page], :per_page => 15)
    else
      @popular_knowledges = Knowledge::Knowledge.published.desc(:clicks).limit(6)
      @latest_knowledges = Knowledge::Knowledge.published.desc(:updated_at).limit(6)
    end
  end

  def search
    @query = Knowledge::Knowledge.search do
      fulltext params[:keyword] do
        highlight :contents
      end
      with :check_status, Knowledge::Knowledge::CHECK_AUDITED
      # order_by :created_at, :desc
      paginate :page => params[:page], :per_page => (params[:size] || 10)
    end
    # @knowledges = @query.results
    @knowledges = []
  end

  def popular
    @knowledges = Knowledge::Knowledge.published.desc(:clicks).paginate(:page => params[:page], :per_page => 20)
  end

  def latest
    @knowledges = Knowledge::Knowledge.published.desc(:updated_at).paginate(:page => params[:page], :per_page => 20)
  end
  
  ##小组文档
  def groups

    if params[:group_id]
      @group = Group.where(_id: params[:group_id]).first unless params[:group_id].blank?
      @knowledges = Knowledge::Knowledge.published.where(:group => @group).paginate(:page => params[:page], :per_page => 20)
      @popular_knowledges = @group.knowledges.published.desc(:clicks).limit(6)
      @latest_knowledges = @group.knowledges.published.desc(:updated_at).limit(6)
    else
      group_ids = Group.get_group_ids_by_user_id current_user.id #用户所在组id
      @groups = Group.find(group_ids)
      @popular_knowledges = Knowledge::Knowledge.published.where(:group_id.ne => nil).desc(:clicks).limit(6)
      @latest_knowledges = Knowledge::Knowledge.published.where(:group_id.ne => nil).desc(:updated_at).limit(6)
    end

    # query = Knowledge.search do
    #   fulltext params[:keyword]
    #   with :public, true
    #   with :group_id, params[:group] if params[:group]
    #   with :group_id, group_ids unless params[:group]
    #   order_by :created_at, :desc
    #   paginate :page => params[:page], :per_page => (params[:size] || 10)
    # end
    # @knowledges = query.results
  end
  
  #我创建的文档
  def my
    @my_unaudited_knowledges = []
    unaudited_knowledges = Knowledge::Knowledge.unaudited
    unaudited_knowledges.each do |knowledge|
      @my_unaudited_knowledges << knowledge if knowledge.group && knowledge.group.creator == current_user
      @my_unaudited_knowledges << knowledge if current_user.is_admin && knowledge.group.nil?
    end
    @knowledges = Knowledge::Knowledge.where(:creator => current_user).desc(:updated_at).paginate(:page => params[:page], :per_page => 20)
    # 清除新文档审核通知
    current_user.notification.reset!(Notification::Knowledge)
    current_user.notification.reset!(Notification::KnowledgeCheck)
    
    # query = Knowledge.search do
    #   fulltext params[:keyword]
    #   with :public, true
    #   with :creator_id, current_user.id
    #   order_by :created_at, :desc
    #   paginate :page => params[:page], :per_page => (params[:size] || 10)
    # end
    # @knowledges = query.results
  end

  def check
    knowledge = Knowledge::Knowledge.find(params[:id])
    # knowledge.check_status = params[:status]
    knowledge.checked_by_user(current_user, params[:status])
    # knowledge.save!

    if knowledge.save
      redirect_to my_knowledge_knowledges_path, notice: "文档审核成功！"
    # else
      # render :action => :new
    end

    # return redirect_to :action => :my, notice: "文档审核成功！" if knowledge.save
  end

  def show
    @knowledge = Knowledge::Knowledge.find params[:id]
    @contents = @knowledge.contents.paginate(:page => params[:page], :per_page => 1)
    return render 'personal_show' if current_user == @knowledge.creator && !@knowledge.published?
    return render 'check_show' if current_user == @knowledge.checked_user && !@knowledge.published?
    @comments = @knowledge.comments.replyed.desc(:created_at)
    Rails.logger.info("-------#{@knowledge}")
    if current_user.id != @knowledge.creator_id && @knowledge.published?
      @knowledge.inc(:clicks, 1) unless params[:page]
    end
  end
  
  def widget
    @knowledges = Knowledge::Knowledge.published
    @knowledges = @knowledges.where(:knowledge_type_id => params[:type]) unless params[:type].blank?
    @knowledges = @knowledges.desc(:created_at).paginate :page => params[:page], :per_page => params[:size] || 10
    render :json => @knowledges
  end
  
  def new
    @knowledge = Knowledge::Knowledge.new
    @knowledge.contents = [Knowledge::KnowledgeContent.new]
    # @knowledge.public = false unless current_user.release_public_knowledge
    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @knowledge = Knowledge::Knowledge.find params[:id]
  end

  def create
    contents_params = params[:knowledge_knowledge].delete(:contents)
    @knowledge = Knowledge::Knowledge.new params[:knowledge_knowledge]
    @knowledge.add_contents(contents_params)
    @knowledge.creator = current_user

    if @knowledge.save
      redirect_to my_knowledge_knowledges_path, notice: "文档创建成功!"
    else
      render :action => :new
    end
    # respond_to do |format|
    #   if @knowledge.save
    #     format.html { redirect_to my_knowledge_knowledges_path, notice: "文章创建成功."}
    #   else
    #     Rails.logger.info("!!!!#{@knowledge.errors.first}")
    #     format.html { render action: "new"}
    #   end
    # end
  end
  
  def update

    contents_params = params[:knowledge_knowledge].delete(:contents)
    @knowledge = Knowledge::Knowledge.find params[:id]
    @knowledge.update_attributes(params[:knowledge_knowledge])
    @knowledge.contents = nil
    @knowledge.contents_count = 0
    @knowledge.add_contents(contents_params)

    # _knowledge = params[:knowledge]
    # if current_user.release_public_knowledge && params[:public].to_i == 1
    #   _knowledge[:public] = true
    #   _knowledge[:group_id] = nil
    # else
    #   _knowledge[:public] = false
    #   @knowledge.status = Knowledge::KNOWLEDGE_STATUS_DRAFT unless _knowledge[:group_id]
    # end
    # respond_to do |format|
    #   if @knowledge.save
    #     format.html { redirect_to action: :my, notice: "文章修改成功."}
    #   else
    #     format.html { render action: :edit}
    #   end
    # end

    # redirect_to :my, :notice => "文章修改成功" and retrun if @knowledge.save
    # render :action => :edit and retrun
    if @knowledge.save
      redirect_to :action => :my, notice: "文档创建成功!"
    else
      render :action => :edit
    end
  end
  
  def destroy
    @knowledge = Knowledge::Knowledge.find params[:id]
    if @knowledge && @knowledge.creator_id == current_user.id
      @knowledge.destroy
    end
    redirect_to  :action => "my"
  end
  
  def delete
    @knowledge = Knowledge.find params[:id]
    if @knowledge && @knowledge.creator_id == current_user.id
      @knowledge.destroy
    end
    redirect_to  :action => "my"
  end
  
  def content
    @knowledge = Knowledge.find params[:id]
    render :layout => nil
  end

end
