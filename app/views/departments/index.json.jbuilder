json.array! @departments.top_scope do |top|
  json.(top, :id, :name)
  json.subs top.subs do |second|
    json.(second, :id, :name)
    json.subs second.subs do |third|
      json.(third, :id, :name)
    end
  end
end
