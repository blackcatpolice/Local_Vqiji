json.array! @members do |member|
  json.(member.user, :id, :name)
end
