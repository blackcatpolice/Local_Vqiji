Weibo::Application.routes.draw do
  namespace :schedule do
    resources :todos, only: [:create, :destroy]
  end

  get 'schedule/:month/todos/count' => 'schedule/todos#month_count'
  get 'schedule/:date/todos' => 'schedule/todos#fullday'
end
