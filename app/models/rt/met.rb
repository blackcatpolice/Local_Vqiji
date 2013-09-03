# encoding: utf-8

module Rt
  # 用户提到 (Mention)
  #
  # 格式:
  # `@name `
  #  请注意结尾空格
  #
  class Met < Token
    field :uid
    field :name
    
    #before_save do |ref|
    #  (ref.tweet.mention ||= Mention.new).user_ids << ref.user_id
    #end
    
    def serializable_hash(options = nil)
      {
        type: 'Mention',
        user: {
          id: uid,
          name: name
        }
      }
    end
      
    def url
      "/users/#{uid}"
    end
    
    def to_html(options = nil)
      content_tag('a', "@#{name} ", href: url, class: 'mention', :'data-user-id' => uid)
    end
    
    MENTION_PATTERN = /@(?<nn>\S+)\s/
    
    def self.tokenizer
      @tokenizer ||= Tokenize::RegexpTokenizer.new(
        MENTION_PATTERN, ->(m) {
          _user = User.find_by_name(m[:nn])
          Met.new(uid: _user.id, name: _user.name) if _user
        }
      )
    end #tokenizer
  end # Met
end
