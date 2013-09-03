class CitiesController < ApplicationController
  caches_page :index
  respond_to :json
  
  def index
    @cities = City.all
  end
end
