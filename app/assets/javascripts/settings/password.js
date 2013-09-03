// require frameworks
//= require libs/jquery/jquery.validate
//= require libs/jquery/jquery.validate.messages_zh
//= require libs/password_strength

(function($){
  "use strict";
  
  $(document).ready(function() {
    $("form#edit-password-form")
      .find("#user_password").on("textchange", _updatePasswordStrength).end()
      .on("submit", _pjax_submit)
      .validate();
  });

  function _updatePasswordStrength() {
    var context = $(this);
    var _passwordStrength = context.siblings(".password-strength");
    if (context.valid()) {
      var strength = PasswordStrength.test(context.val());
      _passwordStrength
          .find(".password-status").hide().end()
          .find(".password-status-" + strength.status()).show().end()
        .show();
    } else {
      _passwordStrength.hide();
    }
  }
  
  function _pjax_submit(event) {
    var target = $(event.target);
    if (target.is("form") && target.valid()) {
      $.pjax.submit(event, "[data-pjax-container]");
    }
  }
})(jQuery);
