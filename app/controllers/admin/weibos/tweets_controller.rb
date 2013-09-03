# encoding: utf-8
# 微博
class Admin::Weibos::TweetsController < Admin::Weibos::BaseController
  def index
    @tweets = Tweet.query(params).paginate :page => params[:page], :per_page => 30
  end
  
  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy
    redirect_to :action=>"index"
  end
end
