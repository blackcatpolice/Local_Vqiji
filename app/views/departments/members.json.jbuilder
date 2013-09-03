json.array! @members do |member|
  json.(member, :id, :name)
end
