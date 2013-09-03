require 'spec_helper'

describe GroupsController do
  it 'should route to #mine' do
    get('/groups/mine').should route_to('groups#mine')
  end
end
