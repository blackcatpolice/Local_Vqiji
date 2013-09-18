# encoding: utf-8

source 'http://ruby.taobao.org'

gem 'rails', '~> 3.2.11'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '>= 1.0.3'
end

gem 'thin'
gem "mongoid", "~> 3.1.4"

gem "mongoid_taggable", "~> 1.1.1"
gem "mongoid_rails_migrations", "~> 1.0.1"
gem "mongo_session_store-rails3", "~> 4.1.1"
gem "mongoid_taggable", "~> 1.1.1"

gem "dynamic_form", "~> 1.1.4"
gem 'devise', '~> 2.2.4'
gem 'oauth', '~> 0.4.6'
gem "cancan", "~> 1.6.10"
gem "resque", "~> 1.24.1"

gem "chinese_pinyin", "~> 0.5.0"
gem 'streamio-ffmpeg', '~> 0.8.5'
gem 'spreadsheet', '~> 0.7.1'
gem 'second_level_cache', '~> 1.5'
gem "whenever", "~> 0.8.2"
gem 'jbuilder', '~> 1.2.0'
gem "strong_parameters", "~> 0.2.1"

gem 'will_paginate', '~> 3.0'
gem 'mongoid_will_paginate', '~> 0.0.2'
gem "bootstrap-will_paginate", "~> 0.0.9"

gem "zipruby", "~> 0.3.6"
gem 'mini_magick'
gem 'carrierwave', '~> 0.6.2'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

gem "yui-compressor", "~> 0.11.0"
gem "jquery-rails", "~> 3.0.2"
gem "pjax_rails", "~> 0.3.4"
gem "jquery-atwho-rails", "0.3.3"
gem "cells", "~> 3.8.8"
gem 'rails_kindeditor'
gem 'rails_autolink'

# full_text_search for mongoid
gem "sunspot_solr", "~> 2.0.0"
gem "sunspot_rails", "~> 2.0.0"
# gem "sunspot_mongo", :git => "git://github.com/balexand/sunspot_mongo.git", :branch => "fix_rake_sunspot_reindex"
gem 'progress_bar'

# gem 'mongoid_fulltext'
group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test, :development do
  gem 'database_cleaner', '~> 0.8.0'
  gem 'faker', '~> 1.0.1'
  gem 'factory_girl_rails', '~> 3.0'
  gem "rspec-rails", "~> 2.13.1"
  gem "capybara", "~> 2.1.0"
  gem "jasmine", "~> 1.3.2"
  gem "shoulda-matchers", "~> 2.1.0"
  
  gem "mina", "~> 0.3.0"
  gem 'turn', '0.8.2', :require => false
end
