json.array! @group_members do |member|
  json.(member.group, :id, :name)
  json.(member, :is_admin)
end
