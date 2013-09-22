require 'spec_helper'

describe Knowledge::KnowledgesController do
  it "首页" do
    get('knowledge/knowledges').should route_to('knowledge/knowledges#index')
  end
  
  describe "编辑知识" do
    it "新建知识" do
      get('knowledge/knowledges/new').should route_to('knowledge/knowledges#new')
    end
    
    it "创建知识" do
      post('knowledge/knowledges').should route_to('knowledge/knowledges#create')
    end
    
    it "修改知识" do
      get('knowledge/knowledges/123/edit').should route_to('knowledge/knowledges#edit', :id => '123')
    end
    
    it "更新知识" do
      put('knowledge/knowledges/123').should route_to('knowledge/knowledges#update', :id => '123')
    end
    
    it "审核知识" do
      put('knowledge/knowledges/123/check').should route_to('knowledge/knowledges#check', :id => '123')
    end
  end
  
  
  
  pending "评论知识" do
    post('knowledge/knowledges/123/knowledge_comments').should route_to('knowledge/knowledge_comments#create', :knowledge_id => '123')
  end
  
  it "收藏知识" do
    get('knowledge/knowledge_collections').should route_to('knowledge/knowledge_collections#index')
  end
  
end
