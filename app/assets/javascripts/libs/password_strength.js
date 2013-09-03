(function(){
  var MULTIPLE_NUMBERS_RE = /\d.*?\d.*?\d/;
  var MULTIPLE_SYMBOLS_RE = /[!@#$%^&*?_~].*?[!@#$%^&*?_~]/;
  var UPPERCASE_LOWERCASE_RE = /([a-z].*[A-Z])|([A-Z].*[a-z])/;
  var SYMBOL_RE = /[!@#\$%^&*?_~]/;

  var PasswordStrength = function(password, username) {
	  var _password = password;
	  var _username = username;
	  var _score = 0;
	  var _status = null;

	  function _test() {
		  _score = 0;

		  _score += scoreFor("password_size");
		  _score += scoreFor("numbers");
		  _score += scoreFor("symbols");
		  _score += scoreFor("uppercase_lowercase");
		  _score += scoreFor("numbers_chars");
		  _score += scoreFor("numbers_symbols");
		  _score += scoreFor("symbols_chars");
		  _score += scoreFor("only_chars");
		  _score += scoreFor("only_numbers");
		  _score += scoreFor("sequences");
		  _score += scoreFor("repetitions");
		  if(_username) _score += scoreFor("username");

		  if (_score < 0) {
			  _score = 0;
		  } else if (_score > 100) {
			  _score = 100;
		  }

		  if (_score < 35) {
			  _status = "weak";
		  } else if (_score < 70) {
			  _status = "good";
		  } else {
			  _status = "strong";
		  }

		  return _score;
	  };
	  
	  this.status = function() {
	    return _status;
	  }

	  this.isGood = function() {
		  return _status == "good";
	  };

	  this.isWeak = function() {
		  return _status == "weak";
	  };

	  this.isStrong = function() {
		  return _status == "strong";
	  };

	  function scoreFor(name) {
		  var score = 0;

		  switch (name) {
			  case "password_size":
				  if (_password.length < 8) {
					  score = -100;
				  } else {
					  score = _password.length * 6;
				  }
				  break;

			  case "numbers":
				  if (_password.match(MULTIPLE_NUMBERS_RE)) {
					  score = 5;
				  }
				  break;

			  case "symbols":
				  if (_password.match(MULTIPLE_SYMBOLS_RE)) {
					  score = 5;
				  }
				  break;

			  case "uppercase_lowercase":
				  if (_password.match(UPPERCASE_LOWERCASE_RE)) {
					  score = 10;
				  }
				  break;

			  case "numbers_chars":
				  if (_password.match(/[a-z]/i) && _password.match(/[0-9]/)) {
					  score = 10;
				  }
				  break;

			  case "numbers_symbols":
				  if (_password.match(/[0-9]/) && _password.match(SYMBOL_RE)) {
					  score = 10;
				  }
				  break;

			  case "symbols_chars":
				  if (_password.match(/[a-z]/i) && _password.match(SYMBOL_RE)) {
					  score = 10;
				  }
				  break;

			  case "only_chars":
				  if (_password.match(/^[a-z]+$/i)) {
					  score = -10;
				  }
				  break;

			  case "only_numbers":
				  if (_password.match(/^\d+$/i)) {
					  score = -10;
				  }
				  break;

			  case "username":
				  if (_password == _username) {
					  score = -100;
				  } else if (_password.indexOf(_username) != -1) {
					  score = -15;
				  }
				  break;

			  case "sequences":
				  score += -15 * sequences(_password);
				  score += -7 * sequences(reversed(_password));
				  break;

			  case "repetitions":
				  score += -(repetitions(_password, 2) * 4);
      		score += -(repetitions(_password, 3) * 3);
      		score += -(repetitions(_password, 4) * 2);
				  break;
		  };

		  return score;
	  };

	  function sequences(text) {
		  var matches = 0;
		  var sequenceSize = 0;
		  var codes = [];
		  var len = text.length;
		  var previousCode, currentCode;

		  for (var i = 0; i < len; i++) {
			  currentCode = text.charCodeAt(i);
			  previousCode = codes[codes.length - 1];
			  codes.push(currentCode);

			  if (previousCode) {
				  if (currentCode == previousCode + 1 || previousCode == currentCode) {
					  sequenceSize += 1;
				  } else {
					  sequenceSize = 0;
				  }
			  }

			  if (sequenceSize == 2) {
				  matches += 1;
			  }
		  }

		  return matches;
	  };

	  function repetitions(text, size) {
		  var count = 0;
  		var matches = {};
		  var len = text.length;
		  var substring;
		  var occurrences;
		  var tmpText;

		  for (var i = 0; i < len; i++) {
			  substring = text.substr(i, size);
			  occurrences = 0;
			  tmpText = text;

			  if (matches[substring] || substring.length < size) {
				  continue;
			  }

			  matches[substring] = true;

			  while ((i = tmpText.indexOf(substring)) != -1) {
				  occurrences += 1;
				  tmpText = tmpText.substr(i + 1);
			  };

			  if (occurrences > 1) {
				  count += 1;
			  }
		  }

		  return count;
	  };

	  function reversed(text) {
		  var newText = "";
		  var len = text.length;

		  for (var i = len -1; i >= 0; i--) {
			  newText += text.charAt(i);
		  }

		  return newText;
	  };
	  
	  _test();
  };

  PasswordStrength.test = function(password, username) {
	  return (new PasswordStrength(password, username));
  };
  
  window.PasswordStrength = PasswordStrength;
})();
