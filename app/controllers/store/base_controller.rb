# encoding: utf-8
# suxu
# 商店 基础控制器
class Store::BaseController < WeiboController
  #
  layout 'layouts/fuli'
  before_filter :doctor_nav,:click_product
  helper_method :click_product
  
   
  #查询出用户最近浏览的商品
  def click_product
    @rproducts = Store::Viewed.desc('updated_at').limit(5)
    # i = 0
    # if session["clicks"]
      # clicks = session["clicks"]
      # clicks.reverse_each do |id|
        # product = Store::Product.find(id)
        # @rproducts << product if product && i<6
        # i = i+1
      # end
    # end
  end
   
end
