require 'spec_helper'

describe NetworkDisksController do
  it 'should route to #download' do
    get('/network_disks/123/download').should route_to('network_disks#download', :network_disk_id => '123')
  end
end
