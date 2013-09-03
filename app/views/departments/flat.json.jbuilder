json.array! @departments do |department|
  json.(department, :id, :name, :pinyin_name)
  json.name department.full_name
end
