# encoding: utf-8

source 'http://ruby.taobao.org'

gem 'rails', '~> 3.2.11'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '>= 1.0.3'
end

# => 代替WebRick作为app-server，先不需要过多的了解
gem 'thin'

# => 与mongodb相关的插件，都不熟悉，还包括
gem "mongoid", "~> 3.1.4"

gem "mongoid_rails_migrations", "~> 1.0.1"
gem "mongo_session_store-rails3", "~> 4.1.1"
gem "mongoid_taggable", "~> 1.1.1"

# => 不知道
gem "dynamic_form", "~> 1.1.4"

# => 都和用户验证相关，都是只看过用过一点，不深入，应该把握机会好好学学
gem 'devise', '~> 2.2.4'
gem 'oauth', '~> 0.4.6'
gem "cancan", "~> 1.6.10"

# => 后端任务，多还了解的
gem "resque", "~> 1.24.1"

# => 拼音工具, 多还了解的
gem "chinese_pinyin", "~> 0.5.0"

# => 视频元信息读取及转码之类的工具，不知道
gem 'streamio-ffmpeg', '~> 0.8.5'
# => excel读写工具, 多还了解的
gem 'spreadsheet', '~> 0.7.1'

# => 二级对象缓存，用过一点点，不深入，可以趁机会好好学学
gem 'second_level_cache', '~> 1.5'

# => 多媒体编辑器，不知的，可以学学
gem 'rails_kindeditor'

# => ruby定时cron写法，了解点，可以先学着
gem "whenever", "~> 0.8.2"

# => 不了解
gem 'rails_autolink'

# => 通过dsl生成json格式的工具，不知道，可以先学着
gem 'jbuilder', '~> 1.2.0'

# => rails4中的强参数验证，抽取过来的，了解一点点，可以试着学学
gem "strong_parameters", "~> 0.2.1"

# => 分页插件，会的
gem 'will_paginate', '~> 3.0'
gem 'mongoid_will_paginate', '~> 0.0.2'
gem "bootstrap-will_paginate", "~> 0.0.9"

# => 配合系统上的ImageMagic用来编辑处理图片的工具，可以再看看用到了哪些不知道的东西
gem 'mini_magick'

# => 上传附件的插件，还可以再好好学学
gem 'carrierwave', '~> 0.6.2'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

# => JavaScript and CSS Compressor, 不知道，可以学学看
gem "yui-compressor", "~> 0.11.0"
gem "jquery-rails", "~> 3.0.2"

# => pjax插件，更高级的ajax效果，了解一点，可以再深入的学学
gem "pjax_rails", "~> 0.3.4"

# => at.js的gem，at.js是一个自动完成的插件，不知道，可以先学着
gem "jquery-atwho-rails", "0.2.3"

# => 分离controller和view的插件，了解过，可以再学学
gem "cells", "~> 3.8.8"

group :development do
  # => 阻止asset的log信息打出，不知道，先不管咯
  gem 'quiet_assets'

  # => 调试利器，用过，继续使用
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'pry'
end

group :test, :development do
  # => 拥有一系列策略来帮助你清空数据库的工具，了解过，没有使用过，可以学着
  gem 'database_cleaner', '~> 0.8.0'

  # => 创建假数据来辅助测试的工具，不知道，好好学学
  gem 'faker', '~> 1.0.1'

  # => 使用工厂方法来产生大量的假数据以供测试使用
  gem 'factory_girl_rails', '~> 3.0'

  # => 代替unit_test的dsl测试框架，用过，还可以继续深入地学学
  gem "rspec-rails", "~> 2.13.1"

  # => 模拟浏览器行为来测试web应用，用过，还需努力学习提高
  gem "capybara", "~> 2.1.0"

  # => BDD开发模式测试js的工具，不知道，有机会学学看
  gem "jasmine", "~> 1.3.2"

  # => 没有搞懂，下来再看
  gem "shoulda-matchers", "~> 2.1.0"
  
  # => 部署项目的工具，用过一点，继续学习
  gem "mina", "~> 0.2.1"

  # => 搞不懂，下来再说
  gem 'turn', '0.8.2', :require => false
end

# => zip压缩相关工具，了解一点，可以在学学看
gem 'zipruby'
