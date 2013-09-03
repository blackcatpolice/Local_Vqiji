# encoding: utf-8
module Store::InvoicesHelper
  
  def invoice_step_msg_help step
    msg = ""
    case step
      when 0 
        msg = "您的申请被拒绝"
      when 1
        msg = "网站审核中，请耐心等待！"
      when 2
        msg = "部门正在审批中，请耐心等待！"
      when 3
        msg = "人事正在进行审批中，请耐心等待！"
      when 4
        msg = "您的报销申请审批成功！"
      end
     return msg
  end
  
  def invoice_step_help step
     case step
      when 0
        msg = "申请被拒绝"
        _class = "label-inverse"
      when 1
        msg = "网站审批中"
        _class = "label-info"
      when 2
        msg = "部门审批中"
        _class = "label-warning"
      when 3
        msg = "人事审批中"
        _class = "label-important"
      when 4
        msg = "申请通过"
        _class = "label-success"
    end
    return "<span class='label #{_class}' title='#{msg}'>#{msg}</span>".html_safe
  end
  
end
