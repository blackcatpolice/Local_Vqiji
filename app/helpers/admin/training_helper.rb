# encoding: utf-8
# 
module Admin::TrainingHelper
  def training_test_option_pages(training)
     options = [
       ['综合测试(不属于任何页)', '']
     ]
     training.pages.each do |page|
      options << [ page.title, page.id ]
     end
     options
  end
end
