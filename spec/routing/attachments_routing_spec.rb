require 'spec_helper'

describe AttachmentsController do

  it 'should routing to #file' do
    post('/attachments/file').should route_to('attachments#file')
  end

  it 'should routing to #audio' do
    post('/attachments/audio').should route_to('attachments#audio')
  end

  it 'should routing to #picture' do
    post('/attachments/picture').should route_to('attachments#picture')
  end
  
  it 'should route to #destroy' do
    delete('/attachments/1').should route_to('attachments#destroy', :id => "1")
  end

  it 'should routing to #download' do
    get('/download/1').should route_to('attachments#download', :id => "1")
  end

  it 'should routable "POST /tmp/audios"' do
    post('/tmp/audios').should route_to('attachments#audio')
  end
end
