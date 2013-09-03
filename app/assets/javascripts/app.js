// require frameworks

//= require libs/socket.io
//= require_tree ./app
//= require_self
//= require widgets.asynch
//= require user/user.usercard

(function($) {
  $(document).ready(function() {
    $("#topnav").topbar();

    // realtime
    App.realtime.triggers.register('alert', $.alert);
    // 接收全局通知
    App.realtime.triggers.subscribe('weibo:realtime/global/trigger');
    // 接收私人通知
    if (typeof($CURRENT_USER) != 'undefined') {
      App.realtime.triggers.subscribe('weibo:realtime/private/' + $CURRENT_USER.id + '/trigger');
    }
    
    // 延迟 5 秒连接，减少快速跳转页面不必要的服务器资源浪费
    setTimeout(function() {
      App.realtime.connect();
    }, 5000);
  });
})(jQuery);
