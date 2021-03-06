# encoding: utf-8

require 'spec_helper'

describe Knowledge do

  describe "发布知识" do
    it "知识标题不能为空！" do
      user = create :user
      knowledge = Knowledge::Knowledge.create(:title => nil,
                                   :creator => user)
      expect(knowledge).to have(1).error_on(:title)
      
    end
  
    describe "公共知识" do
      
      it "单页知识" do
        user = create :user
        knowledge = Knowledge::Knowledge.create(:title => "Test Knowledge1",
                                   :creator => user,
                                   :contents => [Knowledge::KnowledgeContent.new(
                                    :content => "Test Content1",
                                    :page_index => 1)])
        knowledge.clicks.should == 0
        knowledge.check_status.should == Knowledge::Knowledge::CHECK_UNAUDITED
        knowledge_content = knowledge.contents.first
        knowledge_content.knowledge.should == knowledge
        knowledge_content.page_index.should == 1
        knowledge.contents_count.should == 1
      end
      
      it "多页知识" do
        user = create :user
        knowledge = Knowledge::Knowledge.create(:title => "Test Knowledge1",
                                   :creator => user,
                                   :contents => [Knowledge::KnowledgeContent.new(
                                    :content => "Test Content1"),
                                   Knowledge::KnowledgeContent.new(
                                    :content => "Test Content2")])
        knowledge.contents_count.should == 2
        knowledge.clicks.should == 0
        knowledge.check_status.should == Knowledge::Knowledge::CHECK_UNAUDITED
        knowledge_content = knowledge.contents.last
        knowledge_content.knowledge.should == knowledge
        knowledge_content.page_index.should == 2
      end
    end
    
    describe "小组文档" do
      it "单页知识" do
        group = create :group
        user = group.creator

        knowledge = Knowledge::Knowledge.create(:title => "Test Knowledge1",
                                   :creator => user,
                                   :group => group,
                                   :contents => [Knowledge::KnowledgeContent.new(
                                    :content => "Test Content1",
                                    :page_index => 1)])
        knowledge.clicks.should == 0
        knowledge.group.should == group
        knowledge.check_status.should == Knowledge::Knowledge::CHECK_UNAUDITED
        knowledge_content = knowledge.contents.first
        knowledge_content.knowledge.should == knowledge
        knowledge_content.page_index.should == 1
        knowledge.contents_count.should == 1        
      end
      
      it "多页知识" do

        group = create :group
        user = group.creator
        knowledge = Knowledge::Knowledge.create(:title => "Test Knowledge1",
                                   :creator => user,
                                   :group => group,
                                   :contents => [Knowledge::KnowledgeContent.new(
                                    :content => "Test Content1"),
                                   Knowledge::KnowledgeContent.new(
                                    :content => "Test Content2")])
        knowledge.contents_count.should == 2
        knowledge.clicks.should == 0
        knowledge.group.should == group
        knowledge.check_status.should == Knowledge::Knowledge::CHECK_UNAUDITED
        knowledge_content = knowledge.contents.last
        knowledge_content.knowledge.should == knowledge
        knowledge_content.page_index.should == 2        
      end
    end
    
    describe "审核知识" do
      it "普通公开文档需要管理员审核" do
        user = create :user
        knowledge = Knowledge::Knowledge.create(:title => "Test Knowledge1",
                                   :creator => user,
                                   :contents => [Knowledge::KnowledgeContent.new(
                                    :content => "Test Content1",
                                    :page_index => 1)])
        knowledge.check_status.should == Knowledge::Knowledge::CHECK_UNAUDITED
        knowledge.checked_by_user(user, Knowledge::Knowledge::CHECK_AUDITED)
        knowledge.check_status.should == Knowledge::Knowledge::CHECK_AUDITED
        knowledge.checked_user.should == user
        knowledge.checked_at.nil?.should be_false
      end
      
      it "小组文档需要小组管理员审核" do
        group = create :group
        user = group.creator
        knowledge = Knowledge::Knowledge.create(:title => "Test Knowledge1",
                                   :creator => user,
                                   :group => group,
                                   :contents => [Knowledge::KnowledgeContent.new(
                                    :content => "Test Content1",
                                    :page_index => 1)])
        knowledge.check_status.should == Knowledge::Knowledge::CHECK_UNAUDITED
        user2 = create :user
        lambda {
          knowledge.checked_by_user(user2, Knowledge::Knowledge::CHECK_AUDITED)
          }.should raise_error
      end
    end
    

    it "评论知识" do
      user = create :user
      knowledge = Knowledge::Knowledge.create(:title => "Test Knowledge1",
                                 :creator => user,
                                 :contents => [Knowledge::KnowledgeContent.new(
                                  :content => "Test Content1"),
                                 Knowledge::KnowledgeContent.new(
                                  :content => "Test Content2")])
      comment = knowledge.comments.create(:content => "Test Comment Content1",
                                :user => user)
      comment.comment_index.should == 1
      knowledge.comments_count.should == 1
    end

    it "收藏知识" do
      
    end
  end
end
