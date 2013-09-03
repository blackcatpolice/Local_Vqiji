# encoding: utf-8

module Rt
  module Tokenize
    # 解析链
    class Chain
      def initialize(tokenizers = [])
        @tokenizers = tokenizers 
      end
      
      def process(text)
        _tokens = [text]
        # 有可解析字符串元素
        _morestr = true
        
        @tokenizers.each do |tokenizer|
          _morestr = false
          
          _tokens.each_with_index do |_text, _result_index|
            # 如果是字符串，拆分
            if _text.kind_of? String then
              _tokens[_result_index] = tokenizer.tokenize(_text)
              _morestr = true
            end
          end
          
          _tokens.flatten!
          break unless _morestr
        end
        
        _tokens.compact
      end
    end
  end
end
