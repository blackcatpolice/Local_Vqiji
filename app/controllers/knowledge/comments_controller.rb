# encoding: utf-8
class Knowledge::CommentsController < WeiboController
  
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
      @knowledges = Knowledge::Knowledge.published
      @knowledges = @knowledges.where(:group_id => params[:group_id]) if params[:group_id]
      @knowledges = @knowledges.where(:knowledge_type_id => params[:type]) if params[:type]
      @knowledges = @knowledges.paginate(:page => params[:page], :per_page => 15)
    else
      @popular_knowledges = Knowledge::Knowledge.published.desc(:clicks).limit(4)
      @latest_knowledges = Knowledge::Knowledge.published.desc(:updated_at).limit(4)
    end
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
    else
      group_ids = Group.get_group_ids_by_user_id current_user.id #用户所在组id
      @groups = Group.find(group_ids)
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
    query = Knowledge.search do
      fulltext params[:keyword]
      with :public, true
      with :creator_id, current_user.id
      order_by :created_at, :desc
      paginate :page => params[:page], :per_page => (params[:size] || 10)
    end
    @knowledges = query.results
  end

  def show
    @knowledge = Knowledge::Knowledge.find params[:id]
    @contents = @knowledge.contents.paginate(:page => params[:page], :per_page => 1)
    # @comment = @knowledge.comments.new
    if current_user.id != @knowledge.creator_id
      @knowledge.clicks += 1
      @knowledge.save
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
    @knowledge = Knowledge.find params[:id]
  end

  def create
    Rails.logger.info("!!!!!!!!!!!!!!!!!!!!!!!")
    knowledge = Knowledge::Knowledge.find(params[:knowledge_id])
    knowledge.comments.create(:content => params[:content], :user => current_user)
    # contents_params = params[:knowledge_knowledge].delete(:contents)
    # @knowledge = Knowledge::Knowledge.new params[:knowledge_knowledge]
    # @knowledge.add_contents(contents_params)
    # @knowledge.creator = current_user
    # Rails.logger.info(@knowledge.contents)
    # xx
    # if current_user.release_public_knowledge && params[:public].to_i == 1
      # @knowledge.public = true
    # else 
      # @knowledge.public = false
      # @knowledge.status = Knowledge::KNOWLEDGE_STATUS_DRAFT unless @knowledge.group_id
    # end

    respond_to do |format|
      if knowledge.save
        format.html { redirect_to knowledge, notice: "文章创建成功."}
      else
        Rails.logger.info("!!!!#{@knowledge.errors.first}")
        format.html { render action: "new"}
      end
    end
  end
  
  def update
    @knowledge = Knowledge.find params[:id]
    _knowledge = params[:knowledge]
    if current_user.release_public_knowledge && params[:public].to_i == 1
      _knowledge[:public] = true
      _knowledge[:group_id] = nil
    else
      _knowledge[:public] = false
      @knowledge.status = Knowledge::KNOWLEDGE_STATUS_DRAFT unless _knowledge[:group_id]
    end
    respond_to do |format|
      if @knowledge.update_attributes _knowledge
        format.html { redirect_to @knowledge, notice: "文章修改成功."}
      else
        format.html { render action: "edit"}
      end
    end
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
