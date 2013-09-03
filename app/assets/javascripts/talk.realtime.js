// require _base

//= require libs/jquery/ui/jquery.ui.effect
//= require libs/jquery/ui/jquery.ui.effect-transfer
//= require libs/jquery/ui/jquery.ui.draggable

//= require_tree ./talk/realtime
//= require_self

$(document).ready(function() {
  setTimeout(function() {
    Talk.realtime.init();
  }, 3000);
});
