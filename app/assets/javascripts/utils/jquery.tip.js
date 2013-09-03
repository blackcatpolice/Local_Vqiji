// tip V2
// 
// 就像这样
//    
//  ——^—————————————
// |                |x|
// |       Body     |
// |                |
//  ————————————————
//
// 用法:
//  $("#tip").tip({
//    trigger: $("#button")
//  });
//
//  #tip:
//
//  <div class="tip" data-closable="true">
//    This is ALL!
//  </div>
//
// require jquery
// require jquery.ui.widget
// require jquery.ui.position
//

(function($) {
  $.widget("ui.tip", {
    options: {
      tipClass: null,
      within: window,
      trigger: null,          // require
      triggerEvents: "click", // require
      closeable: true,        // 是否显示关闭按钮
      autoOpen: false,
      csses: {
        zIndex: 100
      }
      // direction: "bottom" / "top" / "right"
    }, // options
    
    _getCreateOptions: function() {
      return {
        direction: this.element.attr("data-direction") || "bottom"
      };
    },
  
    _create: function() {
      this._position = $.ui.tip.positions[ this.options.direction ];

      // arrow: 顶部的那个尖尖
      var _arrow = $('<div class="arrow"></div>');
      // close button
      var _close = $('<div class="tp_close" title="关闭"></div>')
        [ this.options.closeable ? 'show' : 'hide' ]();
      // content
      var _content = $('<div class="content"></div>')
        .append(this.element);
      // widget
      this._widget = $('<div class="tip hide"></div>')
        .addClass( this.options.tipClass || "" )
        .addClass( this._position.tipClass )
        .css( this.options.csses )
        .append( [ _arrow, _close, _content ] )
        .appendTo(document.body);

      this._on({
        "click .tp_close": this.close,
        "resize": this._delayResetPosition
      });

      this._on(this.options.within, { resize: this._delayResetPosition });
      
      if (this.options.trigger) {
        if (this.options.triggerEvents) {
          var events = {};
          events[this.options.triggerEvents] = this.open;
          this._on(this.options.trigger, events);
        }
      }
      
      this._isOpen = false;
    },// _create
    
    widget: function() {
      return this._widget;
    }, // widget
    
    _init: function() {
      if (this.options.autoOpen) {
        this.open();
      }
    }, // _init
    
    _setOption: function(key, value) {
      if (key === "closeable") {
        this.element.find(".tp_close")[ value ? "show" : "hide" ]();
      }
      this._superApply([key, value]);
    }, // _setOption
    
    _destroy: function() {
      this._widget.remove();
    }, // _destroy
    
    // 对齐位置
    resetPosition: function() {
      if (this.options.trigger) {
        this._widget.position({
          of: this.options.trigger,
          my: this._position.postition.my,
          at: this._position.postition.at,
          collision: "none"
        });
      }
      return this;
    }, // resetPosition
    
    _delayResetPosition: function(timeout) {
      if (this._delayResetPositionTimer) {
        clearTimeout(this._delayResetPositionTimer);
      }
      this._delayResetPositionTimer = setTimeout($.proxy(function() {
        this.resetPosition();
        this._delayResetPositionTimer = null;
      }, this), timeout || 20);
    },
    
    open: function() {
      if (!this._isOpen) {
        this._isOpen = true;
        this._widget.show();
        this._delayResetPosition(20);
        this._trigger("open");
      }
      return this;
    }, // open
    
    close: function() {
      if (this._isOpen) {
        this._widget.hide();
        this._isOpen = false;
        this._trigger("close");
      }
      return this;
    }, // close
    
    isOpen: function() {
      return this._isOpen;
    }
  });
  
  $.ui.tip.positions = {
    top: {
      tipClass: 'tp_na',
      postition: {
        my: "left-58 bottom-8",
        at: "center top"
      }
    },
    bottom: {
      tipClass: 'bp_na',
      postition: {
        my: "left-47 top+5",
        at: "center bottom"
      }
    },
    left: {
      tipClass: 'lp_na',
      postition: {
        my: "right-8 top-45",
        at: "left center"
      }
    },
    right: {
      tipClass: 'rp_na',
      postition: {
        my: "left+8 top-35",
        at: "right center"
      }
    }
  };
})(jQuery);
