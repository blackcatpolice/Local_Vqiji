json.array! @feeds do |feed|
	json.partial! 'talk/feeds/feed', feed: feed
end
