# encoding: utf-8
class KnowledgesController < WeiboController
  
  layout proc { |c| pjax_request? ? pjax_layout : 'knowledge' }

  #所有公开的文档
  def index
    @knowledges = Knowledge.published.where(:public => true)
    @knowledges = @knowledges.where('$or' => [ 
      { title: /#{params[:keyword]}/i },
      { pinyin_title: /#{params[:keyword]}/i }
    ]) unless params[:keyword].blank?
    @knowledges = @knowledges.where(:knowledge_type_id => params[:type]) unless params[:type].blank?
    @knowledges = @knowledges.desc(:created_at).paginate :page => params[:page], :per_page => params[:size] || 10
    @knowledge_types = KnowledgeType.all.asc(:priority)

    respond_to do |format|
      format.html 
      format.json { 
        knowledges = []
        @knowledges.collect do |k|
          knowledges << k.title
        end
        render :json => knowledges 
      }
    end
  end
  
  ##小组文档
  def groups
    group_ids = Group.get_group_ids_by_user_id current_user.id #用户所在组id
    @group = Group.where(_id: params[:group]).first unless params[:group].blank?
    @knowledges = Knowledge.published.where(:public => false)
    unless params[:group].blank?
      @knowledges = @knowledges.where(group_id: group_ids.include?(params[:group]) ? params[:group] : nil)
    else
      @knowledges = @knowledges.in(group_id: group_ids) 
      @knowledges = @knowledges.where('$or' => [ 
        { title: /#{params[:keyword]}/i },
        { pinyin_title: /#{params[:keyword]}/i }
      ]) unless params[:keyword].blank?    
    end
    @knowledges = @knowledges.desc(:created_at).paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html
      format.json { 
        knowledges = []
        @knowledges.collect do |k|
          knowledges << k.title
        end
        render :json => knowledges 
      }
    end
  end
  
  #我创建的文档
  def my
    @knowledges = Knowledge.where(:creator_id => current_user.id)
    @knowledges = @knowledges.where('$or' => [ 
      { title: /#{params[:keyword]}/i },
      { pinyin_title: /#{params[:keyword]}/i }
    ]) unless params[:keyword].blank?
    @knowledges = @knowledges.desc(:created_at).paginate :page => params[:page], :per_page => 10
    respond_to do |format|
      format.html 
      format.json { 
        knowledges = []
        @knowledges.collect do |k|
          knowledges << k.title
        end
        render :json => knowledges 
      }
    end
  end

  def show
    @knowledge = Knowledge.find params[:id]
    if current_user.id != @knowledge.creator_id
      @knowledge.clicks += 1
      @knowledge.save
    end
  end
  
  def widget
    @knowledges = Knowledge.published.where(:public => true)
    @knowledges = @knowledges.where(:knowledge_type_id => params[:type]) unless params[:type].blank?
    @knowledges = @knowledges.desc(:created_at).paginate :page => params[:page], :per_page => params[:size] || 10
    render :json => @knowledges
  end
  
  def new
    @knowledge = Knowledge.new
    @knowledge.public = false unless current_user.release_public_knowledge
    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @knowledge = Knowledge.find params[:id]
  end

  def create
    @knowledge = Knowledge.new params[:knowledge]
    @knowledge.creator_id = current_user.id
    if current_user.release_public_knowledge && params[:public].to_i == 1
      @knowledge.public = true
    else 
      @knowledge.public = false
      @knowledge.status = Knowledge::KNOWLEDGE_STATUS_DRAFT unless @knowledge.group_id
    end

    respond_to do |format|
      if @knowledge.save
        format.html { redirect_to @knowledge, notice: "文章创建成功."}
      else
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
