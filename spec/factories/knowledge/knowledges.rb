# Read about factories at https://github.com/thoughtbot/factory_girl
# encoding:utf-8
FactoryGirl.define do
  factory :knowledge, :class => 'Knowledge::knowledge' do
    title "测试会议主题"
    location "测试会议地址"
    #    end_date { start_date + rand(30).days }
    # association :user, factory: :user, strategy: :create
  end
end
