class Schedule::Service
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def todos
    @user.schedule_todos
  end

  def meetings
    @user.schedule_meetings
  end
  
  # Mongoid 3.0 使用 map-reduce 重构
  #map = %Q{
  #  function() {
  #    emit(this.at.toDateString(), this);
  #  }
  #}

  #reduce = %Q{
  #  function(key, values) {
  #    return {
  #      date: (new Date(Date.parse(key))),
  #      count: values.length
  #    };
  #  }
  #}
  #  .map_reduce(map, reduce)
  #  .out(inline: 1)
  def count_todos_by_month(month)
    begin_date = month.beginning_of_month
    end_date   = month.end_of_month

    todos = user.schedule.todos
      .in_range(begin_date.beginning_of_day, end_date.end_of_day)

    count = {}
    sys_count = {}

    # 初始化
    begin_date.upto(end_date) do |date|
      count[date] = sys_count[date] = 0
    end
    
    # 统计每天的待办事项和系统待办事项
    todos.each do |todo|
      todo_at_date = todo.at.to_date
      count[todo_at_date] = count[todo_at_date] + 1
      if todo.is_a? ::Schedule::SysTodo
        sys_count[todo_at_date] = sys_count[todo_at_date] + 1
      end
    end
    
    result = {}
    # 合并结果
    begin_date.upto(end_date) do |date|
      result[date] = {
        count: count[date],
        sys: sys_count[date]
      }
    end

    result
  end
end
