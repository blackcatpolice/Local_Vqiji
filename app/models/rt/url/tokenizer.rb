# tokenizer

class Rt::Url
  module Tokenizer
    def tokenizer
      @tokenizer ||= ::Rt::Tokenize::RegexpTokenizer.new(
        /(?<ul>#{ regexp })/,
        ->(matchData) {
          _longUrl = expand(matchData[:ul])
          _url = discern( _longUrl )
          _url && _url.to_token
        }
      )
    end # tokenizer
  end
end
