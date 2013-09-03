json.array! @cities.distinct(:country) do |country|
  json.country country
  json.provinces @cities.where(:country => country).distinct(:province) do |province|
    json.province province
    json.cities @cities.where(:country => country, :province => province) do |city|
      json.(city, :id, :name, :province, :country)
    end
  end
end
