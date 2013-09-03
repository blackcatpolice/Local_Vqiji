# encoding: utf-8
module Elearn::TrainingsHelper
   def link_to_training_status(training_user)
    training = training_user.training
    # 已通过 => 查看详细
    return "#{link_to '',elearn_training_path(training),:class=>'zt6'}".html_safe if training_user.pass #已通过
    # 已过期
    return "#{link_to '','javascript:;',:class=>'zt0',  :style=>'cursor:default;'}".html_safe if training.timeout #已过期
    # 未开始 => 进入学习
    return "#{link_to '',elearn_training_page_path( :training_id => training.id, :id => training.pages.asc("number").first.id),:class=>'zt1'}".html_safe unless training_user.start #未开始
    # 未完成 => 继续学习
    return "#{link_to '',elearn_training_page_path( :training_id => training.id, :id => training.pages.asc("number").first.id),:class=>'zt2'}".html_safe unless training_user.finished #未完成
    # 未考核 => 进入考试
    return "#{link_to '',elearn_training_tests_path(:training_id=>training.id),:class=>'zt3'}".html_safe unless training_user.exam #未考试
    # 未评分
    return "#{link_to '','javascript:;',:class=>'zt4', :style=>'cursor:default;'}".html_safe unless training_user.check #未评分
    # 未通过 => 重新考试
    return "#{link_to '',elearn_training_tests_path(training),:class=>'zt5'}".html_safe unless training_user.pass #未通过
  end
end
