;(function() {
  var defaultOptions = {
    serializeArray: $.fn.serializeArray,
    ajax: {
      method: 'POST',
      dataType: 'json'
    }
  };

  $.rtext.rtextEditor.formSubmit = function(form, options) {
    var _options = $.merge(defaultOptions, options)
      , context = $(form);
    
    var _submit = function(_, done) {
      var url = (_options.url || context.attr("action"));
      _args = $.extend(true, {}, _options.ajax); 
      
      if (_args.complete) {
        var _complete = _args.complete;
        _args.complete = function() {
          done();
          _complete.apply(this, arguments);
        }
      }
      
      _args.data = _options.serializeArray.call(context);
      $.ajax(url, _args);
    }
    
    return _submit;
  }
})(jQuery);
