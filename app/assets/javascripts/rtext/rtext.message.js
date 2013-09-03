// require jQuery
// require jQuery.ui.widget
// require jquery.alert
// require jquery.confirm
// require rtext.attachments

/*
 * 这是神马？
 *
 * 亲！您是不是为统一的改动一个有 Rtext，附件，删除按钮等特性的消息 Widget 上的某个小特性
 * 而搞的大小便失禁？ 今天，我将这些统一特性封装为这个 Widget，你只需要遵守一点点约定就可以
 * 治好您的大小便失禁。
 *
 * 这个widget实现了消息的：
 *  1. 名片显示
 *  2. 附件查看
 *  3. 删除
 *  4. （未完待序）
 *
 * 约定：
 *  1. 消息有一个顶级dom，且有属性 data-id 来表示它的 ID
 *  2. 删除按钮必须设置 data-action="delete"
 *  3. 附件由一个设置属性 data-role="rtext-attachments" 的 dom 包含，
 *  4. 视频链接 <div class="rtext'> <a class="video-url" ...></a></div>
 *  目前支持的附件有 (图片，音频，视频链接, 文件)
 *  4. （有了再说）
 *
 * 祝您早日康复！
 */

(function($){
  $.widget("rtext.rtextMessage", {
    options: {
    },
    
    _create: function() {
      $.extend(true, this.options, {
        /* FIX IE: delete => delete_ */
        delete_: {
          animate: true,
          confirm: "删除?",
          apiFunc: function(id, opts) {
            $.alert("删除未实现！", 2);
          }
        }
      });

      this._tokens = this.element.find(".rtext").rtextTokens();
      this._attachments = this.element.find(" > [data-role=rtext-attachments]")
        .rtextAttachments({ message: this })
        .rtextAttachments("attachVideoUrls", this._tokens.rtextTokens("videoUrlTokens"));
      
      if (this.options.delete_ !== false) {
        this.delete_.proxy = $.proxy(this.delete_, this);
        this.element.find("[data-action=delete]").bind("click", this.delete_.proxy);
      }
    },
    
    // 获取消息 ID
    _messageId: function() {
      return this.element.attr("data-id");
    },
    
    // ------ 删除 --------
    
    // 删除 Widget
    remove: function() {
      var _remove = $.proxy(function() {
        this.element.remove();
        this._trigger("removed");
        this.destroy();
      }, this);
    
      if (this.options.delete_.animate) {
        this.element.slideUp("fast", _remove);
      } else {
        _remove();
      }
      return this;
    },
    
    // 删除绑定的消息并删除 Widget
    delete_: function() {
      if (this.options.delete_ === false) return this;
      var context = this;
      
      var _remoteDelete = $.proxy(function() {
        context.disable();
        this.options.delete_.apiFunc.apply(this, [this._messageId(), {
          success: function() {
            context.remove()._trigger("deleted");
          },
          error: WEIBO.ui.errorHandler,
          complete: $.proxy(context.enable, context)
        }]);
      }, this);

      $.confirm(this.options.delete_.confirm, function(confirm) {
        if (confirm) {
          _remoteDelete();
        }
      });
      return this
    },
    
    // ------ /删除 --------

    // 销毁 Widget
    _destroy: function() {
      if (this.delete_.proxy) {
        this.element.find("[data-action=delete]").unbind("click", this.delete_.proxy)
        this.delete_.proxy = null;
      }
      
      if(this._attachments) {
        this._attachments.rtextAttachments("destroy");
        this._attachments = null;
      }
    }
  });
})(jQuery);
