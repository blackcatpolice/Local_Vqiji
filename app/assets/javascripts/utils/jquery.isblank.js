(function() {    
  // 空白文本？
  $.isBlank = function(text) {
    return !!(!text || text.match(/^\s*$/));
  };
})(jQuery);
