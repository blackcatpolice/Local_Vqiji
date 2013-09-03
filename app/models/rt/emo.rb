# encoding: utf-8

module Rt
  # 表情 (Emotion)
  #
  # == 格式:
  #  [囧]
  #
  class Emo < Token
    field :code
    
    def url
      Emotion.url(code)
    end
    
    def serializable_hash(options = nil)
      {
        :type => 'Emotion',
        :code => code,
        :url  => url
      }
    end
    
    def to_html(options = nil)
      tag('img', src: url, class: 'emotion', title: code)
    end
    
    EMOTION_PATTERN = /\[(?<cd>[^\]]+)\]/
    
    def self.tokenizer
      @tokenizer ||= Tokenize::RegexpTokenizer.new(
        EMOTION_PATTERN, ->(matchData) {
          if Emotion.exists?(matchData[:cd])
            Emo.new(:code => matchData[:cd])
          end
        }
      )
    end #tokenizer
  end # Emo
end
