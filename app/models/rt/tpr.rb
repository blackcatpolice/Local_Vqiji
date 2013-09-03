# encoding: utf-8

module Rt
  # 话题
  # Topic Reference
  #
  # == 格式:
  #  #topic#
  #
  # == 说明：
  #  topic_title 长度不超过32
  #
  class Tpr < Token
    field :title
    
    def url
      "/topics/#{title}"
    end
    
    def serializable_hash(options = nil)
      {
        :type  => 'TopicRef',
        :topic => {
          :title  => title
        }
      }
    end
    
    def to_html(options = nil)
      content_tag('a', "##{title}#", href: url, class: 'topic-ref')
    end
    
    TOPIC_PATTERN = /#(?<tp>[^#]{#{Topic::TITLE_MINLEN},#{Topic::TITLE_MAXLEN}})#/
    
    def self.tokenizer
      @tokenizer ||= Tokenize::RegexpTokenizer.new(
        TOPIC_PATTERN, ->(matchData) {
          Tpr.new(:title => matchData[:tp])
        }
      )
    end #tokenizer
  end # Tpr
end
