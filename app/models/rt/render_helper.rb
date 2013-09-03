# encoding: utf-8

module Rt
  module RenderHelper
    #
    def render_rtext(tokens)
      _elems = tokens.collect(&:to_html)
      content_tag('span', _elems.join(''), { :class => 'rtext' }, false)
    end
    
    alias rtext_tag render_rtext
    
    self.extend ActionView::Helpers::TagHelper
    self.extend self
  end
end
