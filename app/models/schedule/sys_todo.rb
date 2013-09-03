class Schedule::SysTodo < Schedule::Todo
  
  SCOPE_TODO_TASK = "Todo::Task" #任务
  SCOPE_TRAINING = "Training"    #培训
  
  field :scope # 来自域
  field :target_id 
  field :target_url
  
  validates :scope, :presence => true
  validates :target_url, :presence => true
  validates :target_id , :presence => true
  
  scope :todo_tasks, where(:scope => SCOPE_TODO_TASK)
  scope :trainings, where(:scope => SCOPE_TRAINING)
  
  def to_builder
    super.instance_eval do |json|
      json.is_sys = true
      json.(:scope, :target_id, :target_url)
      json
    end
  end
end
