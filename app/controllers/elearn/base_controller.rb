# encoding: utf-8
# 培训
#
class Elearn::BaseController < WeiboController
  layout proc { |c| pjax_request? ? pjax_layout : 'layouts/elearn' }
end
