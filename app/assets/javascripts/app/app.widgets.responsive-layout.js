// require jquery
// require app.responsive-layout

/*
  widget 相应式布局
*/
(function($, undefined) {
  var row1, row2
    , mergedWidgets = [];
  
  // 合并 widget
  function merge() {
    row2.children().each(function(_, elem) {
      if ( $(elem).is("[wrl-strategy=prepend]") ) {
        row1.prepend(elem);
      } else {
        row1.append(elem);
      }
      mergedWidgets.push(elem);
    });
  }

  // 还原
  function restore() {
    $(mergedWidgets).appendTo(row2);
    mergedWidgets.splice(0);
  }
  
  function doWith(mode) {
    // 在 1024 模式下合并 widgets 到 row1
    (mode == '1024') ? merge() : restore();
  }

  function _onDisplayModeChanged(e, newMode) {
    doWith(newMode);
  }

  $(function() {
    row1 = $("[wrl-row1]");
    row2 = $("[wrl-row2]");

    doWith( App.getDisplayMode() );
    $(document.body).on("displaymodechanged", _onDisplayModeChanged);
  });
})(jQuery);
