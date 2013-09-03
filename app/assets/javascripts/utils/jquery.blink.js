/*
 * blink plugin base on jQuery
 * http://github.com/x290431695/jquery.blink
 *
 * VERSION 0.0.0
 *
 * Writen by Xiao Fuhai <xiaofuhai0@gmail.com>
 * Useage: $("input.username").blink();
 *
 * require jquery
 * require jquery.color
 */


(function($, undefined) {
  $.fn.blink = function(options, callback) {
    //JavaScript中arguments函数对象是该对象代表正在执行的函数和调用它的函数的参数。
    if ((arguments.length == 1) && $.isFunction(options)) {
      callback = options;
      options = null;
    }
    
    var _options = $.extend(
      true, // deep merge
      {
        highlight: {
          backgroundColor: "red",
          opacity: 0.4
        },       // highlight css style
        times: 2 // blink times
      }, // default options
      options
    );
    
    //
    this.each(function(idx, elem) {
      var self = $(elem);
      
      // 绑定回调后返回
      if (callback) {
        self.one("after-blink", callback);
      }
      
      // 正在闪动
      if (self.data("blinking")) {
        return this;
      }
      
      // 标记正在闪动
      self.data("blinking", true);

      // 原始状态
      var _original = {};
      // 保存初始化状态
      $.each(_options.highlight,
        function(key) {
          _original[key] = self.css(key);
        }
      );
      
      // 一次闪动
      function _blink(callback) {
        // 高亮
        self.animate(_options.highlight, 100, function() {
          // 还原
          self.animate(_original, 150, callback);
        });
      }
      
      // 闪动次数
      var _blinkedTimes = 0;

      //
      var _loopBlink = function () {
        _blink(
          function() {
            ++ _blinkedTimes;
            // 闪够没？
            if (_blinkedTimes < _options.times) {
              _loopBlink();// 没闪够,再闪！
            } else {// 闪够了 T_T
              // 清除正在闪动标记
              self.data("blinking", null);
              // 回调
              self.trigger("after-blink");
            }
          }
        )
      }
      
      // 闪动吧！
      _loopBlink();
    });
    
    return this;
  }
})(jQuery);
