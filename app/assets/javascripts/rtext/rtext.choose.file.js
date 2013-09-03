(function($) {
	$.widget("rtext.chooseFile", {
		_create: function(){
			this._on({
			  "click .tip-disk-list :checkbox" : this._onCheckboxClick
			});
		  this._loadFileList();
		},

		_loadFileList: function(){
			var context = this;
			this.element.html('<div class="tip-disk-loading"><img src="/assets/loading.gif" />加载网盘文件中...</div>');
			WEIBO.attachmentDisks({
	    	success: function(data) {
	    		if (data.length == 0) {
			  		context.element.html('<div class="tip-disk-alert">网盘里没有文件</div>');
			  	} else {
			  		var _tip_disk_list = $('<div class="tip-disk-list" />');
			  		
			  		$.tmpl('<label class="checkbox" title="${name}"><input type="checkbox" name="tip-disk-file" value="${id}">${$.truncate(name, 30)}</label>', data).appendTo(_tip_disk_list);
			  		_tip_disk_list.appendTo(context.element);
			  		$('.tip-disk-loading', context.element).remove();
			  		this._fileList = _tip_disk_list;
			  		context._trigger("resize");
			  	}
	    	},
	    	error: function() {
	    		context.element.html('<div class="tip-disk-error">加载网盘文件失败！</div>');
		  		context._trigger("resize");
	    	}
		 	});
		},
		
		_onCheckboxClick: function(e) {
		  var $target = $(e.target);
		  if ($target.prop("checked")) {
		    if (this._$currentCheckbox) {
		      this._$currentCheckbox.prop("checked", false);
		    }
		    this._file = $target.parent('.checkbox').tmplItem().data;
		    this._$currentCheckbox = $target;
			  this._trigger("selected", null, this._file);
		  } else {
		    this._$currentCheckbox = null;
		    this._file = null;
				this._trigger("deleted");
  		}
		},
		
		file: function() {
		  return this._file;
		},
		
		reset: function() {
		  if (this._fileList) {
			  $('.checkbox :checkbox', this._fileList).prop('checked', false);
			}
			if (this._$currentCheckbox) {
	      this._$currentCheckbox.prop("checked", false);
			  this._$currentCheckbox = null;
			}
	    this._file = null;
	    return this;
		},
		
		_destroy: function() {
		  if (this._fileList) {
		    this._fileList.remove();
		  }
		  this._$currentCheckbox = null;
		  this._file = null;
		}
	});
})(jQuery);
