require 'spec_helper'

describe 'schedule/todos/fullday.html.erb' do
  let(:todo) { create :schedule_todo, detail: '下班', at: '2013-6-6 18:00:00' }
  let(:sys_todo) { create :schedule_sys_todo, detail: '下班', at: '2013-6-7 18:00:00' }

  before :each do
    @todos = [todo, sys_todo]
    render
  end
  
  it 'should render 2 items' do
    rendered.should have_selector("li[data-id]", :count => 2)
  end
  
  it 'should render id' do
    rendered.should have_selector("[data-id=\"" + todo.to_param + "\"]", :count => 1)
  end
  
  it 'should render detail' do
    rendered.should have_text("下班", :count => 2)
  end
  
  it 'should render at' do
    rendered.should have_text("18:00", :count => 2)
  end
  
  it 'should render 1 DELETE link' do
    rendered.should have_link("删除", :count => 1)
  end
  
  it 'should render attribute: is-sys=true' do
    rendered.should have_selector("li[data-id=\"" + sys_todo.to_param + "\"][is-sys=true]", :count => 1)
  end
end
