require 'spec_helper'

describe NotificationsController do
  it 'should route to #index' do
    get('/notifications').should route_to('notifications#index')
  end
  
  it 'should route to #board' do
    get('/notifications/board').should route_to('notifications#board')
  end
  
  it 'should route to #count' do
    get('/notifications/count').should route_to('notifications#count')
  end
end
