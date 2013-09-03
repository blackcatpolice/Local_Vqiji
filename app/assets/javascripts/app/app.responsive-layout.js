// require jquery
/*
  相应式显示模式（响应式布局）：
    分辨率 < 1280 => '1024'
    分辨率 == 1280 => '1280'
    分辨率 > 1280 => 'wide'
*/
(function($, undefined) {
  var _delayResizeTimer, $window, $body;

  function setDisplayMode(mode, triggerEvent) {
    if ( getDisplayMode() != mode ) {
      $body.attr("display-mode", mode)
      if (triggerEvent !== false) {
        $body.trigger("displaymodechanged", mode);
      }
    }
  }
  
  function getDisplayMode() {
    return $body.attr("display-mode") || "1280";
  }

  // 检测最优模式
  function detectBestModel() {
    var width = $window.width();
    // 为什么不是 < 1280 ? 应为可能受到滚动条的影响本来
    // 是 1280 分辨率的显示器的 widget 比 1280 小那么一点点
    if (width < 1230) { 
      return "1024";
    } else if (width > 1280) {
      return "wide";
    }
    return "1280";
  }

  function _onResize() {
    if (_delayResizeTimer) {
      clearTimeout(_delayResizeTimer);
    }
    // 延迟调模式，优化性能
    _delayResizeTimer = setTimeout(function() {
      setDisplayMode( detectBestModel() );
      _delayResizeTimer = null;
    }, 500);
  }
  
  $(function() {
    $window = $(window);
    $body = $(document.body);
    // 为防止在 document.ready 由于事件绑定顺序引起的逻辑混乱，
    // 这里的模式设置不触发事件
    setDisplayMode( detectBestModel(), false );
    // 导出接口
    // App.setDisplayMode = setDisplayMode;
    App.getDisplayMode = getDisplayMode;

    $window.resize(_onResize);
  });
})(jQuery);
