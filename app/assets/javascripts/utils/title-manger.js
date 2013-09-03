// require jquery

/*
 * title 管理器
 *
 * author: bmm<xiaofuhai0@gmail.com>
 * @ 2013-6-22 
 *
 * 实现 title 的优先级管理和滚动显示
 */
(function($, undefined) {
  var TitleManager_ = {

    titles: {},
    current: null,

    _idSeed: 0,
    _sortedByPriorityTitles: {},
    _maxPriority: 0,

  	/*
  	 * 添加一个标题，并返回 id
  	 */
  	add: function(title, options) {
  	  if( !title ) {
  	    return;
  	  }

  	  var _id = (++ this._idSeed)
  	    , _options = $.extend(true, {}, TitleManager_.defaultOptions, options);
  	    
      var _titleObj = {
  	    title: title,
  	    options: _options
  	  };

  	  this.titles[_id] = _titleObj;

  	  // 按照优先级排序
  	  var _priortity = this._sortedByPriorityTitles[ _options.priority ] || [];
  	  _priortity.unshift( _titleObj );
  	  this._sortedByPriorityTitles[ _options.priority ] = _priortity;

      // 更高优先级 title 被加入
  	  if (_options.priority >= this._maxPriority) {
  	    this._setCurrent(_titleObj);
  	    this._maxPriority = _options.priority;
  	  }

  	  return _id;
    },

    /*
     * 删除一个 title
     */
    remove: function(id) {
      var _titleObj = this.titles[ id ];
      if ( !_titleObj ) {
        return;
      }

      try {
        delete this.titles[ id ];
      } catch (e) {
        this.titles[ id ] = null;
      }

  	  // 
  	  var _priortity = this._sortedByPriorityTitles[ _titleObj.options.priority ];
  	  _priortity.splice( $.inArray( _titleObj, _priortity), 1 );

  	  if (_priortity.length == 0) {
  	    this._sortedByPriorityTitles[ _titleObj.options.priority ] = null;
  	    // 最高优先级发生改变
  	    if (_titleObj.options.priority == this._maxPriority) {
  	      var _max = 0;
  	      $.each(this._sortedByPriorityTitles, function(priority, _) {
  	        if ( parseInt(priority) > _max ) {
  	          _max = parseInt(priority);
  	        }
  	      });
  	      this._maxPriority = _max;
  	    }
  	  }
      
      // 当前 title 被删除
      if (this.current == _titleObj) {
        var nextTitleObj = this._sortedByPriorityTitles[ this._maxPriority ][0];
  	    this._setCurrent( nextTitleObj );
      }
    },
    
    _setCurrent: function(titleObj) {
      if ( this.isMarquee() ) {
        this.stopMarquee();
      }

      this.current = titleObj;
      
      if ( titleObj ) {
        if (titleObj.options.marquee) {
          this.startMarquee();
        } else {
          document.title = titleObj.title;
        }
      } else {
        document.title = "";
      }
    },
    
    /* 滚动 title */
    marqueeTimer: null,

    startMarquee: function() {
      var title = this.current.title
        , options = this.current.options
        , maxSubTitleIndex = title.length - 1
        , subTitleIndex = 0
        , subTitleLength = 8;

      this.marqueeTimer = setInterval(function() {
        document.title = subTitle();
      }, 300);

      function subTitle() {
        if (subTitleIndex <= maxSubTitleIndex) {
          return title.substr(subTitleIndex ++, subTitleLength);
        } else {
          subTitleIndex = 0;
          return title.substr(subTitleIndex, subTitleLength);
        }
      }
    },
    
    stopMarquee: function() {
      clearInterval(this.marqueeTimer);
    },

    isMarquee: function() {
      return this.marqueeTimer != null;
    }
  };
  
  TitleManager_.defaultOptions = {
    priority: 0,
    marquee: false
  };

  TitleManager_.add(document.title);

  window.TitleManager = TitleManager_;
})(jQuery);
