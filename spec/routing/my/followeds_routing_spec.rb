require 'spec_helper'

describe My::FollowedsController do
  it 'should routing to #create' do
    post('/my/followeds').should route_to('my/followeds#create')
  end

  it 'should routing to #destroy' do
    delete('/my/followeds/1').should route_to('my/followeds#destroy', id: '1')
  end

  it 'should routing to #query' do
    get('/my/followeds/query').should route_to('my/followeds#query')
  end
end
