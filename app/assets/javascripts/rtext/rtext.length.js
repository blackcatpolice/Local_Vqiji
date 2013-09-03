// require jquery
// 计算 rtext 长度

(function($) {
  $.rtextLength = function(text) {
    return Math.ceil(
      text.replace(/[^x00-xff]/g, "aa").length / 2.0
    );
  }
  
  $.fn.rtextLength = function() {
    return $.rtextLength(this.val());
  }
})(jQuery);
