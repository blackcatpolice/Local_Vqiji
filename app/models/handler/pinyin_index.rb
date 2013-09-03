#将name 转换为拼音
#
module Handler
	module PinyinIndex
	  extend ActiveSupport::Concern

	  included do
    	field :pinyin_name, :type => String # 名称拼音
			field :pinyin_index, :type => String, :default => '!' # 拼音索引
			
			before_save do |user|
			  if user.name_changed?
	        user.pinyin_name = Pinyin.t(user.name, splitter: '')
          index = user.pinyin_name[0].downcase
          user.pinyin_index = (index =~ /[a-z]/i) ? index : '!'
        end
			end
		end
	end
end
