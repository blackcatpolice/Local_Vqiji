# encoding: utf-8

# 提到当前用户的评论
module My
  class Mention::CommentsController < MentionsController
    def index
      @comments = Comment.mention_user(current_user.id)
         .paginate(:page => params[:page], :per_page => 10)
         
      render
      current_user.notification.reset!(Notification::CommentMention)
    end
  end
end
