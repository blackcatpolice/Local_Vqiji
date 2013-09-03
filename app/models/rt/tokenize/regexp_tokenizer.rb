# encoding: utf-8

module Rt
  module Tokenize
    # 正则表达式 Tokenizer
    class RegexpTokenizer < Tokenizer
      def initialize(pattern, matched)
        @pattern = pattern
        @matched = matched
      end

      private
      
      def _matched(matchData)
        @matched.call(matchData)
      end
      
      public
      
      def tokenize(text)
        # 已经处理文本结束位置
        _matched_pos = 0
        # 匹配开始位置
        _start_pos = 0
        # 记录当前解析器的结果
        _tokens = []
        
        # 使用循环一个查询符合当前解析器表达式规则的文本段
        while(_match = text.match(@pattern, _start_pos)) do
          # 设置下次匹配开始位置为本次匹配结果结束位置
          _start_pos = _match.end(0)
          # 获取匹配结果
          if (_token = _matched(_match))
            # 配解析成功，清理 _matched_pos 和本次匹配结果开始位置之间的文本
            if (_matched_pos < _match.begin(0))
              _tokens << text[_matched_pos..(_match.begin(0) - 1)]
            end
             
            # ** 在添加本次解析结果前处理并解析保证元素顺序正确 **
            _tokens << _token
            
            # 获取到结果，记录并设置 _matched_pos 为本次匹配结果结束位置
            _matched_pos = _match.end(0)
          end # 如果匹配失败，不移动 _matched_pos, 继续下次匹配
        end
        
        if (_matched_pos < text.length)
          _tokens << text[_matched_pos..(text.length - 1)]
        end
        
        _tokens
      end
    end # RegexpTokenizer
  end
end
