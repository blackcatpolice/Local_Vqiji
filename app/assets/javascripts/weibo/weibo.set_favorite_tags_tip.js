(function($) {
  $.widget("weibo.weiboSetFavoriteTagsTip", {
    _create: function() {
       this._input = this.element.find(".texter")
        .placeholder();

       this._on({
         "click .tags .tag": this._onTagClick,
         "click .btn-ok": this._onOkClick,
         "click .btn-cancel": this._onCancelClick
       });
       
      this._noteView = this.element.find(".tip_note_i");
      this._noteDefaultMsg = this._noteView.text();
       
      this.element.tip({
         tipClass: "tip-favorites-tip",
         trigger: this.options.trigger,
         triggerEvents: null,
         // direction: "bottom",
         autoOpen: true,
         autoCloseWhenClickOutside: true,
         open: $.proxy(this._onOpen, this),
         close: $.proxy(this._onClose, this)
       });
    },
    
    _destroy: function() {
      this.element.tip("destroy");
    },
    
    tags: function() {
      var _tagsStr = this._input.val();
      var tags = [];
      $.each( _tagsStr.split(/\s/), function(_, tag) {
        var _trimedTag = $.trim(tag);
        if (_trimedTag && (-1 == $.inArray(_trimedTag, tags))) {
          tags.push(_trimedTag);
        }
      } );
      return tags;
    },
    
    _addTag: function(tag) {
      var tags = this.tags();
      if (tag && (-1 == $.inArray(tag, tags))) {
        tags.push(tag);
      }
      this._input.val( tags.join(' ') + " " ).focus();
    },
    
    _onTagClick: function(event) {
      var tag = $(event.target).attr("title");
      if (tag) {
        this._addTag(tag);
      }
    },
    
    _submit: function(success) {
      var tags = this.tags();
      
      if (tags.length < 1) {
        this._showError("请至少输入一个标签");
        this._input.blink();
        return false;
      }
      
      var _tweetId = this.element.data("tweet-id")
        , self = this;
      
      $.ajax("/my/favorites/" + _tweetId + "/tags", {
        dataType: 'json',
        method: 'PUT',
        data: {
          tags: tags.join(' ')
        },
        
        success: function() {
          self.disable();
          success.call(self);
        },
        error: function(jqXHR, httpStatus, throwErrors) {
          var error = App.error.XHRError(jqXHR, httpStatus, throwErrors, '设置标签失败！');
          self._showError(error);
          self.enable();
        }
      });

      return true;
    },
    
    _showError: function(msg) {
      this._noteView.text(msg).addClass("error");
    },
    
    _restoreNote: function() {
      this._noteView.text(this._noteDefaultMsg).removeClass("error");
    },
    
    reset: function() {
      this._restoreNote();
    },
    
    open: function() {
      this.element.tip("open");
      return this;
    },
    
    close: function() {
      this.element.tip("close");
      return this;
    },
    
    _onOkClick: function() {
      this._submit(function() {
        this._trigger("ok");
      });
    },
    
    _onCancelClick: function() {
      this._trigger("cancel");
    },
    
    _onOpen: function() {
      this._trigger("open");
    },
    
    _onClose: function() {
      this._trigger("close");
    }
  });
})(jQuery);
