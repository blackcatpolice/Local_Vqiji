class Widgets::WeatherController < ApplicationController
  def t
    @scope = Widget::Weather::Scope.where(:name => params[:search]).first
    @code = (@scope && @scope.code) || Pinyin.t(params[:search], splitter: '')

    render :json => {
      search: params[:search],
      code: @code
    }
  end
end
