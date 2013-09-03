// require jquery
// require utils/title-manager

// 滚动标题
(function($, TitleManager, undefined) {
  var titleId = null;

  function updateTitle(count) {
    if (titleId) {
      TitleManager.remove(titleId);
    }

    if (count > 0) {
      var title = "【您有 " + count + " 条新私信】";
      titleId = TitleManager.add(title, { marquee: true });
    } else {
      titleId = null;
    }
  }

  Talk.realtime.Counter.listen("changed", updateTitle);
})(jQuery, window.TitleManager);
