# encoding: utf-8
class Knowledge::CommentsController < WeiboController
  
  layout proc { |c| pjax_request? ? pjax_layout : 'knowledge' }

  before_filter :except => [:create] do
    @comment = Knowledge::Comment.find(params[:id])
  end

  def reply_comments
    @comments = @comment.reply_comments.desc(:created_at)
    respond_to {|format| format.js}
  end

  def reply_comment
    @comment = @comment.reply_comments.create(:content => params[:content], 
                                   :user => current_user,
                                   :is_reply => true,
                                   # :reply_to_user_id => params[:reply_to_user_id],
                                   :knowledge => @comment.knowledge)
    respond_to {|format| format.js}
  end



  def create
    knowledge = Knowledge::Knowledge.find(params[:knowledge_id])
    @comment = knowledge.comments.create(:content => params[:content], :user => current_user)
    respond_to {|format| format.js}
  end
  
  def destroy
    @comment.destroy
    respond_to {|format| format.js}
  end
end
