# encoding: utf-8
#
module Rt
  # 富文本 (Rich Text) 标记
  class Token
    include ActionView::Helpers::TagHelper
    include Mongoid::Document
    
    embedded_in :rtowner
    
    def to_html(options = nil)
      ""
    end
    
    class << self
      def tokenizer
        nil
      end
    end
  end
end
