# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Dir[File.join(Rails.root, 'db', 'seeds', '**', '*.rb')].each { |seed| load seed }

if Rails.env != 'production'
  User.create({ :password => '12345678', :password_confirmation => '12345678', :email => "admin@vqiji.com", :name => "管理员", :checked=>true, :is_admin => true }, as: :admin)
end
