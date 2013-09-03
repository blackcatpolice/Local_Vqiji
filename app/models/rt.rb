# encoding: utf-8

module Rt
  class << self
    def tokenize(text, tokens = [])
      tokens << Txt unless tokens.include?(Txt)
      _tokenizers = []
      tokens.each do |token|
        unless (token.respond_to?(:tokenizer))
          raise "`tokenizer` isn't defined in #{token}!"
        end        
        _tokenizers << token.tokenizer
      end      
      _tokenizers.compact
      Tokenize::Chain.new(_tokenizers).process(text)
    end # /tokenize
  end
end
