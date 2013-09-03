require 'spec_helper'

describe Devise::SessionsController do
  describe 'routing' do
    it 'sign_in_path to #new' do
      get(sign_in_path).should route_to('devise/sessions#new')
    end
   
    it 'sign_out_path to #destroy' do
      get(sign_out_path).should route_to('devise/sessions#destroy')
    end
  end
end
