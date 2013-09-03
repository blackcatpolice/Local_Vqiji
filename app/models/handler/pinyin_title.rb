#将name 转换为拼音
#
module Handler
  module PinyinTitle
    extend ActiveSupport::Concern

    included do
      field :pinyin_title, :type => String # 名称拼音
      field :pinyin_index, :type => String, :default => '!' # 拼音索引
      
      before_save do |model|
        return unless model.title_changed?
        model.pinyin_title = Pinyin.t(model.title, splitter: '')
        index = model.pinyin_title[0].downcase
        model.pinyin_index = (index =~ /[a-z]/i) ? index : '!'
      end
    end
  end
end
