//= require jquery
//= require libs/_base
//= require libs/jquery/jquery.histroy
//= require_self
//= require jquery.pjax

// Fix pushState on browers which did't suport.
if ((!(window.history.pushState &&
       window.history.replaceState)) && window.History) {
  History.Adapter.bind(window,'statechange',function(){
      window.history.state = History.getState();
  });

  window.history.state = window.History.getState();  
  window.history.pushState = window.History.pushState;
  window.history.replaceState = window.History.replaceState;
}
