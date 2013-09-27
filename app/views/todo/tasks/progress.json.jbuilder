logs = @task.logs.changed_progress.asc(:created_at).only(:created_at, :progress)

min = (if first = logs.first
  (first.created_at <= @task.start_at) ? logs.first.created_at : @task.start_at
else
  @task.start_at
end).to_i * 1000

max = (if @task.completed?
  @task.timeout? ? @task.end_at : @task.completed_at
else
  (@task.end_at > Time.now) ? @task.end_at : Time.now      
end).to_i * 1000

ticks = [min, max]

data = [ [min, 0] ]
logs.each do |log|
  data << [ log.created_at.to_i * 1000, log.progress ]
end

markings = [{
  xaxis: { from: @task.end_at.to_i * 1000, to: @task.end_at.to_i * 1000 },
  color: 'red'
}]

json.status 200
json.min min
json.max max
json.ticks ticks
json.data data
json.markings markings
