# encoding: utf-8

# 培训的测试
class TrainingTest
  include Mongoid::Document

  TYPE_RADIO = "radio" #单选题
  TYPE_CHECKBOX = "checkbox" #多选题
  TYPE_TEXT = "text" #填空题
  TYPE_TEXTAREA = "textarea" #问答题

  belongs_to :training, class_name: 'Training' #培训
  belongs_to :page, class_name: 'TrainingPage' #培训页

  OPTION = ["A","B","C","D","E","F"]

  field :type, type: String ,default:"radio"# 题目类型
  field :question, type: String #问题
  field :remark, :type => String #备注
  field :score, type: Integer,default: 1 #题目分数
  field :options, type: Array,default: Array.new #答案选项 ，(客观题时，必须输入)
  field :answers, type: Array,default: Array.new #题目答案，(客观题时，必须输入)
  field :answer, type: String #答案
  field :answer_input_type, type: String

  scope :sub_scope, ->(training_id) {
    where(:training_id => training_id, :page_id => nil)
    .where("$or" => [ { :type => 'text' },{ :type => 'textarea' }])
  }
  
  # 类型名
  def type_desc
    return "单选题" if type == "radio"
    return "多选题" if type == "checkbox"
    return "填空题" if type == "text"
    return "问答题" if type == "textarea"
  end
  
  # 客观题
  def objective?
    return self.type == "radio" || self.type == "checkbox"
  end
  
  # 主观题
  def subjective?
    return self.type == "text" || self.type == "textarea"
  end
  
  alias :objective :objective?
  alias :subjective :subjective?
  
  #主观题目，没有选项和标准答案
  before_save do |test|
    test.options = Array.new if test.subjective
    test.answers = Array.new if test.subjective
  end

  #
  after_create :increase_counter_cache
  
  def increase_counter_cache
    self.training.inc(:tests_count,1) if self.training
    self.page.inc(:tests_count,1) if self.page
  end
  
  #
  after_destroy :decrease_conuter_cache
  
  def decrease_conuter_cache
    self.training.inc(:tests_count,-1) if self.training && self.training.tests_count > 0
    self.page.inc(:tests_count,-1) if self.page && self.page.tests_count > 0
  end
  
  class << self
    def find_by_id(id)
      where(:id => id).first
    end
    
    alias :get :find_by_id
  end
end
