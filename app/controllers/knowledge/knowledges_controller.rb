# encoding: utf-8
class Knowledge::KnowledgesController < WeiboController
  
  layout proc { |c| pjax_request? ? pjax_layout : 'knowledge' }

  after_filter :only => [:show] do
    @knowledge.inc(:clicks, 1) if @knowledge.published? && @knowledge.creator != current_user && params[:page].nil?
  end

  before_filter :except => [:index, :search, :popular, :latest, :groups, :my, :widget, :new, :create] do
    @knowledge = Knowledge::Knowledge.find params[:id]
  end

  after_filter :only => [:pass_audit, :not_pass_audit] do
    @knowledge.deliver_audited_notification
  end

  after_filter :only => [:publish] do
    @knowledge.deliver_auditing_notification
  end

  def index
    @knowledge_types = Knowledge::Type.all.asc(:priority)
    @knowledge_type = Knowledge::Type.find(params[:type]) if params[:type]
    @group = Group.find(params[:group_id]) if params[:group_id]
    conditions = {:check_status => 2}
    conditions.merge!(:group_id => params[:group_id]) if params[:group_id]
    conditions.merge!(:knowledge_type_id => params[:type]) if params[:type]

    @knowledges = Knowledge::Knowledge.where(conditions).paginate(:page => params[:page], :per_page => 20)

    @popular_knowledges = Knowledge::Knowledge.published.desc(:clicks).limit(6)
    @latest_knowledges = Knowledge::Knowledge.published.desc(:updated_at).limit(6)
  end

  def search
    @query = Knowledge::Knowledge.search do
      fulltext params[:keyword] do
        highlight :contents
      end
      with :check_status, Knowledge::Knowledge::CHECK_AUDITED
      paginate :page => params[:page], :per_page => (params[:size] || 10)
    end
  end

  def popular
    @title = "热门阅读"
    @knowledges = Knowledge::Knowledge.published.desc(:clicks).paginate(:page => params[:page], :per_page => 20)
    render 'knowledge/knowledges/simple_index'
  end

  def latest
    @title = "最近更新"
    @knowledges = Knowledge::Knowledge.published.desc(:updated_at).paginate(:page => params[:page], :per_page => 20)
    render 'knowledge/knowledges/simple_index'
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

  end
  
  #我创建的文档
  def my
    @my_unaudited_knowledges = []
    unaudited_knowledges = Knowledge::Knowledge.unaudited
    unaudited_knowledges.each do |knowledge|
      @my_unaudited_knowledges << knowledge if knowledge.can_audit?(current_user)
    end
    @knowledges = Knowledge::Knowledge.where(:creator => current_user).desc(:updated_at).paginate(:page => params[:page], :per_page => 20)
    # 清除新文档审核通知
    current_user.notification.reset!(Notification::Knowledge)
    current_user.notification.reset!(Notification::KnowledgeCheck)
  end

  def show
    @contents = @knowledge.contents.paginate(:page => params[:page], :per_page => 1)
    @content = @contents.first
    return render 'personal_show' if current_user == @knowledge.creator && !@knowledge.published?
    return render 'check_show' if @knowledge.can_audit?(current_user) && !@knowledge.published?
    @comments = @knowledge.comments.replyed.desc(:created_at)
  end
  
  def widget
    @knowledges = Knowledge::Knowledge.published
    @knowledges = @knowledges.where(:knowledge_type_id => params[:type]) unless params[:type].blank?
    @knowledges = @knowledges.desc(:created_at).paginate :page => params[:page], :per_page => params[:size] || 10
    render :json => @knowledges
  end
  
  def new
    @knowledge = Knowledge::Knowledge.new
    @knowledge.contents = [Knowledge::Content.new]
  end
  
  def edit
    # @knowledge = Knowledge::Knowledge.find params[:id]
  end

  def create
    contents_params = params[:knowledge_knowledge].delete(:contents)
    params[:knowledge_knowledge].delete(:group_id) if params[:public] == '1'
    @knowledge = Knowledge::Knowledge.new params[:knowledge_knowledge]
    @knowledge.add_contents(contents_params)
    @knowledge.creator = current_user

    if @knowledge.save
      redirect_to my_knowledge_knowledges_path, notice: "文档创建成功!"
    else
      render :action => :new
    end
  end
  
  def update
    contents_params = params[:knowledge_knowledge].delete(:contents)
    @knowledge.update_attributes(params[:knowledge_knowledge])
    @knowledge.contents = nil
    @knowledge.contents_count = 0
    @knowledge.add_contents(contents_params)
    if @knowledge.save
      redirect_to my_knowledge_knowledges_path, notice: "文档修改成功!"
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @knowledge && @knowledge.creator_id == current_user.id
      @knowledge.destroy
    end
    redirect_to  :action => "my"
  end

  def pass_audit
    @knowledge.audit_by_user(current_user, Knowledge::Knowledge::CHECK_AUDITED)
    redirect_to my_knowledge_knowledges_path, :notice => "文档审核成功！" if @knowledge.errors.blank?
  end

  def not_pass_audit
    @knowledge.audit_by_user(current_user, Knowledge::Knowledge::CHECK_AUDITED)
    redirect_to my_knowledge_knowledges_path, :notice => "文档审核成功！" if @knowledge.errors.blank?
  end

  def publish
    @knowledge.publish(@knowledge.can_audit?(current_user))
    redirect_to my_knowledge_knowledges_path, :notice => "文档发布成功！" if @knowledge.errors.blank?  
  end

  def draft
    @knowledge.draft
    redirect_to my_knowledge_knowledges_path, :notice => "文档保存草稿成功！" if @knowledge.errors.blank?
  end

end
