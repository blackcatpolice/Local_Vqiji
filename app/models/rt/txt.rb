# encoding: utf-8
require 'cgi'

module Rt
  # 普通文字
  # Text
  class Txt < Token
    field :text
    field :htxt
    
    def serializable_hash(options = nil)
      {
        :type => 'Text',
        :text => text
      }
    end
    
    def to_html(options = nil)
      htxt || text
    end
    
    TEXT_PATTERN = /(?<ee>.+)/m
    
    def self.tokenizer
      @tokenizer ||= Tokenize::RegexpTokenizer.new(
        TEXT_PATTERN, ->(matchData) {
          _text = matchData[:ee]
          _htxt = CGI::escapeHTML(_text)
          Txt.new(:text => _text, :htxt => _htxt)
        }
      )
    end #tokenizer
  end # Txt
end
