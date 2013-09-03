## encoding: utf-8
## 综合培训
##
class Fuwu::BaseController < WeiboController
  # 综合服务默认使用 fuwu模板
  layout proc { |controller| controller.request.xhr? ? nil : 'layouts/fuwu' }

end
