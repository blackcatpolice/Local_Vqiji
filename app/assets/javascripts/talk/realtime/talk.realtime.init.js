(function($) {
  // 初始化私信聊天
  Talk.realtime.init = function() {
    var _init = Talk.realtime.init;
    Talk.realtime.init = $.noop;
    
    Talk.realtime.Session.prepare({
      success: function() {
        $.talk.talkRealtimeSidebar.init();
        $.talk.talkWindow.init();
        _initWindowForCurrentSession();
      },
      error: function() {
        Talk.realtime.init = _init;
        $.alert("初始化私信聊天失败！", "错误", 2);
      }
    });
  };
  
  function _initWindowForCurrentSession() {
    // 如果存在当前会话，创建最小化窗口
    if (Talk.realtime.Session.current) {
      $.talk.talkWindow.instance()
        .talkWindow("minimize", false)
        .talkWindow("add", Talk.realtime.Session.current);
    }
  }
})(jQuery);
