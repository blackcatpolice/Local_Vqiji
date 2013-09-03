json.array! @feeds do |feed|
  json.(feed, :id)
  json.html json.partial!(partial: 'talk/feeds/rt_feed', formats: [ :html ], locals: { feed: feed })
end
