# encoding: utf-8
# suxu
# 商店 基础控制器
class Fuli::BaseController < WeiboController
  layout 'layouts/fuli'
  before_filter :doctor_nav
  
   
end
