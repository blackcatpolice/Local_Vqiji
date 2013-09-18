require 'spec_helper'

describe My::FavoritesController do

  it 'should routing to #index' do
    get('/my/favorites').should route_to('my/favorites#index')
  end

  it 'should routing to #index_untagged' do
    get('/my/favorites/untagged').should route_to('my/favorites#index_untagged')
  end

  it 'should routing to #index_tagged' do
    get('/my/favorites/tagged').should route_to('my/favorites#index_tagged')
  end

  it 'should routing to #create' do
    post('/my/favorites').should route_to('my/favorites#create')
  end

  it 'should routing to #destroy' do
    delete('/my/favorites/1').should route_to('my/favorites#destroy', tweet_id: '1')
  end

  it 'should routing to #set_tags' do
    put('/my/favorites/1/tags').should route_to('my/favorites#set_tags', tweet_id: '1')
  end
  
  it 'should routing to #set_tags_tip' do
    get('/my/favorites/1/tags_tip').should route_to('my/favorites#set_tags_tip', tweet_id: '1')
  end
  
end
