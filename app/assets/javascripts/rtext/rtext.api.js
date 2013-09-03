// require jquery

(function() {
  window.Rtext.api = new function() {
    // 删除附件
    this.deleteAttachment = function(id, options) {
      var _args = $.extend(
        true, {}, API.defaultOptions, options, 
        {
          type: "DELETE"
        }
      );

      $.ajax("/attachments/" + id + ".json", _args);
    };
    
    // 创建短链接
    this.shortenURL = function(url, options) {
      var _args = $.extend(
        true, {}, API.defaultOptions, options,
        {
          type: "POST",
          cache: true,
          data: { url: url }
        }
      );
      
      $.ajax("/urls/shorten.json", _args);
    };
    
    // 验证视频链接
    this.validVideoURL = function(url, options) {
      var _args = $.extend(
        true, {}, API.defaultOptions, options,
        {
          type: "POST",
          cache: true,
          data: { url: url }
        }
      );
      
      $.ajax("/urls/valid_video_url.json", _args);
    };
  };
})(jQuery);
