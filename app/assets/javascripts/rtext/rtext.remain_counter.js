// 剩余字数提示框

//
// require jquery
// require rtext.length
// require jquery.textchange
//
(function($) {
  $.widget("rtext.rtextRemainCounter", {
    options: {
      target: null, // 文本输入框
      maxLength: 140,
      formater: {
        remain: function(remainCount, maxCount) {
          return '您还可以输入<span class="remain">' + remainCount + '</span>个字';
        },
        over: function(overCount, maxCount) {
          return '输入已经超过了<span class="over">' + overCount + '</span>个字';
        }
      } // 默认提示文字
    },
    
    _init: function() {
      this.update();
    },
    
    _create: function() {
      // 文字编辑框
      this._texter = $(this.options.target);
      // texter 不能为空
      if (this._texter.length == 0) {
        $.error("target can't be blank!");
      }
      // 绑定 updator
      this.update.proxy = $.proxy(this.update, this);
      this._texter.bind("textchange", this.update.proxy);
    },
    
    _setOption: function(key, value) {
      this._superApply([key, value]);
      // 修改 maxLength
      if (key === "maxLength" 
        && value != this.options.maxLength) {
        this.update();
      }
    },
    
    _destroy: function() {
      // 取消 updater 绑定
      if (this.update.proxy) {
        this._texter.unbind("textchange", this.update.proxy);
        this.update.proxy = null;
      }
    },
    
    // 剩余字数
    remainCount: function() {
      return this.options.maxLength - this._texter.rtextLength();
    },
    
    reset: function() {
      this.update();
      return this;
    },
    
    // 更新提示
    update: function() {
      var _remainCount = this.remainCount();
      var _tips = null;
      // 创建 tips 提示
      if (_remainCount >= 0) {
        _tips = this.options.formater.remain(_remainCount, this.options.maxLength);
      } else {
        _tips = this.options.formater.over(- _remainCount, this.options.maxLength);
      }
      //
      this.element.html(_tips);
      return this;
    }
  });
  
})(jQuery);
