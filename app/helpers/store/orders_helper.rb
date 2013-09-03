# encoding: utf-8
module Store::OrdersHelper
  def order_status_help status
    _class = ""
    msg = ""
    title = ""
    case status
      when 0
        msg = "未提交"
        title = "点击填写订单"
      when 1
        msg = "已提交"
        title = msg
        _class = "label-info"
      when 2
        msg = "送货中"
        title = msg
        _class = "label-warning"
      when 3
        msg = "确认收货"
        title = msg
        _class = "label-important"
      when 4
        msg = "订单完成"
        title = msg
        _class = "label-success"
      else
        msg = "订单被拒绝"
        title = msg
        _class = "label-inverse"
    end
    return "<span class='label #{_class}' title='#{title}'>#{msg}</span>".html_safe
  end
end
