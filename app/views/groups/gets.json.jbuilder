json.array! @groups do |group|
  json.(group, :id, :name)
end
