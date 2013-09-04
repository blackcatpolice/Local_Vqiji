// 富文本编辑框

//
// require jquery
// require jquery.msie
// require jquery.placeholder
//
(function($) {
  $.widget("rtext.rtextTexter", {
    options: {
      preset: "",
      placeHolder: null
    },
  
    _create: function() {
      //this.element.placeholder();
      // 为了使ie在失去焦点后仍然保持selection状态，
      // 在input失活前(before deactivate)保存selection
      if ($.msie()) {
        this._on({
          "beforedeactivate" : this._saveSelection
        });
      }
    },
    // 恢复 selection
    _restoreSelection: function() {
      if (this._savedSelection) {
        this._savedSelection.select();
      }
    },
   // 保存 selection
    _saveSelection: function() {
      if (document.selection) {
        this._savedSelection = document.selection.createRange().duplicate();
      }
    },
    
    caret: function() {
      return this.element.caret();
    },
    
    _init: function() {
      this.reset();
    },
    
    disable: function() {
      this.element.attr("disabled", "disabled");
      return $.Widget.prototype.disable.call(this);
    },
    
    enable: function() {
      this.element.removeAttr("disabled");
      return $.Widget.prototype.enable.call(this);
    },
    
    _setOption: function(key, value) {
      if (key === "placeHolder") {
        this.element.attr("placeholder", value);
      }
      return $.Widget.prototype._setOption.call(this, key, value);
    },
    
    reset: function() {
      this.element
        .val(this.options.preset || "")
        .attr("placeholder", this.options.placeHolder);
      this._savedSelection = null;
    },
    
    text: function(text) {
      if (arguments.length == 1) {
        this.element.val(text || "");
      } else {
        // 如果当前显示的是 placeholder
        if (this.element.hasClass("placeholder")) {
          return "";
        }
        return this.element.val();
      }
    },
    
    /*
     * 选中指定区域的文字
     */
    select: function(start, end) {
      if (arguments.length == 1) end = start;
      this.element.caret(start, end);
      // 重新保存 selection
      if ($.msie()) {
        this._saveSelection();
      }
    },
    
    // 写入文字（插入/替换）
    // 返回文字的写入位置
    write: function(text) {
      // ie 特有，恢复selection
      if ($.msie() && (document.activeElement != this.element[0])) {
        this._restoreSelection();
      }
      var range = this.element.caret();
      this.element.val(range.replace(text));
      var endpos = range.start + text.length;
      this.element.caret(endpos, endpos);
      if ($.msie()) {
        this._saveSelection();
      }
      return [range.start, endpos];
    },
    
    // 插入文字
    // select: 是否选中插入后的文字
    insert: function(text) {
      return this.write(text);
    },
  
    // 追加文字
    append: function(text) {
      this.select(this.text().length);
      return this.write(text);
    },
    
    // 前置文字
    preppend: function(text) {
      this.select(0);
      return this.write(text);
    }
  });
})(jQuery);

/*
 *
 * Copyright (c) 2010 C. F., Wong (<a href="http://cloudgen.w0ng.hk">Cloudgen Examplet Store</a>)
 * Licensed under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 */
(function($) {
  $.fn.caret = function(options, opt2) {
	  var start, end, t = this[0], browser = $.msie();
    if(typeof options === "object" && typeof options.start === "number" && typeof options.end === "number") {
	    start = options.start;
	    end = options.end;
    } else if(typeof options === "number" && typeof opt2 === "number") {
	    start = options;
	    end = opt2;
    } else if(typeof options === "string") {
	    if((start = t.value.indexOf(options)) > -1) {
	      end = start + options.length;
	    } else {
	      start = null;
	    }
    } else if(Object.prototype.toString.call(options) === "[object RegExp]") {
	    var re = options.exec(t.value);
	    if(re != null) {
		    start = re.index;
		    end = start + re[0].length;
	    }
    }
	  if(typeof start != "undefined") {
		  if(browser) {
			  var selRange = this[0].createTextRange();
			  selRange.collapse(true);
			  selRange.moveStart('character', start);
			  selRange.moveEnd('character', end - start);
			  selRange.select();
		  } else {
			  this[0].selectionStart = start;
			  this[0].selectionEnd = end;
		  }
		  this[0].focus();
		  return this;
	  } else {
		  // Modification as suggested by Андрей Юткин
      if(browser) {
		    var selection=document.selection;
        if (this[0].tagName.toLowerCase() != "textarea") {
          var val = this.val(),
          range = selection.createRange().duplicate();
          range.moveEnd("character", val.length);
          var s = (range.text == "" ? val.length : val.lastIndexOf(range.text));
          range = selection.createRange().duplicate();
          range.moveStart("character", -val.length);
          var e = range.text.length;
        } else {
          var range = selection.createRange(),
          stored_range = range.duplicate();
          stored_range.moveToElementText(this[0]);
          stored_range.setEndPoint('EndToEnd', range);
          var s = stored_range.text.length - range.text.length,
          e = s + range.text.length
        }
		   // End of Modification
      } else {
			  var s = t.selectionStart, e = t.selectionEnd;
		  }
		  var te = t.value.substring(s,e);
		  return {
		    start: s, end: e, text: te,
		    replace: function(st) {
			    return t.value.substring(0,s) + st + t.value.substring(e,t.value.length);
		    }
		  };
	  }
  };
})(jQuery);
