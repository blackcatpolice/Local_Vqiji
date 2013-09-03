// 工具栏
// 
//  require jQuery
//  require ui.tip
//
(function($) {

  $.widget("rtext.toolbar", {
    options: {
      tool: {
        class_: null
      },
      tip: null
    },
    
    _create: function() {
      this.element.addClass("toolbar");
    },
    
    destroy: function() {
      var context = this;
      //删除所有 tool 和 tip
      $.each(this._tools(), function(index, tool) {
        var _tip = context._tooltip(tool);
        if (_tip) {
          _tip.tip("destroy").remove();
        }
        $(tool).remove();
      });
      return $.Widget.prototype.destroy.call(this);
    },
    
    _tooltip: function(tool, tip) {
      var $tool = $(tool);
      if (tip) {
        $tool.data("_tip", tip);
        _tip = tip;
      } else {
        _tip = $tool.data("_tip");
      }
      return _tip;
    },
    
    addTool: function(tool, tip, options) {
      var context = this,
          $tool = $(tool);
      var _options = $.extend(true, { triggerEvent: 'click' }, options);
      $tool
        .data("toolbar-tool-options", _options)
        .addClass(this.options.tool.class_)
        .addClass("tool") // 添加强制样式避免破坏 toolbar
        .data("tip", tip)
        .appendTo(this.element)
        .one(_options.triggerEvent, function() {
          context.triggerTool($tool, "open");
        });
      return this;
    }, // addTool
    
    // 创建 tip
    _createToolTip: function(tool) {
      var context = this,
          _tipBuilder = tool.data("tip"),
          _tip = $($.isFunction(_tipBuilder) ? _tipBuilder.call(this) : $(_tipBuilder));
      
      if (_tip.length == 0) {
        $.error("tip can't be blank!");
      }
      
      var _options = tool.data("toolbar-tool-options");
      
      _tip.appendTo(this.element).tip($.extend(true, {}, this.options.tip, {
        tipClass: _options.tipClass,
        trigger: tool,
        autoOpen: false
      }))
      .bind('tipopen', function(event) {
        var _tool = $(this).tip("option", "trigger");
        if (context._current != _tool) {
          // 关闭当前打开的 tip
          context.triggerTool(context._current, "close");
          context._current = _tool;
        }
      })
      .bind("tipclose", function(event) {
        context._current = null;
      });
      return this._tooltip(tool, _tip);
    },
    
    triggerTool: function(tool, method) {
      var $tool = $(tool)
        , _tip = this._tooltip($tool);

      // 延迟创建 tip (第一次打开时创建)
      if (method === "open" && (!_tip)) { //
        _tip = this._createToolTip($tool);
      }
      
      if (_tip) {
        // close
        // destroy
        // resetPosition
        _tip.tip(method);
      }
      return this;
    }, // _triggerTool
    
    _tools: function() {
      return $(".tool", this.element);
    },
    
    // 关闭所有工具
    closeAllTools: function() {
      var context = this;
      $.each(this._tools(), function(index, tool) {
        var _tip = context._tooltip(tool);
        if (_tip) {
          _tip.tip("close");
        }
      });
      return this;
    }
  }); // widget
})(jQuery);
