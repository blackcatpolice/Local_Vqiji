Weibo::Application.routes.draw do
  # mount resque
  mount Resque::Server.new, :at => '/resque'
end
