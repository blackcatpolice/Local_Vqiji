json.extract! feed, :id
json.html json.partial!(partial: 'talk/feeds/feed', formats: [ :html ], locals: { feed: feed })
