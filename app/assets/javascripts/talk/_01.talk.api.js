//
// 私信 api
//
// require jquery
// require API

(function($) {
  "use strict";
  
  Talk.api = new function() {
    var context = this;
    
    // API 默认参数
    var _defaultOptions = API.defaultOptions;
    
    // 发送私信
    this.talkTo = function(session_id, text, options) {
      //
      var _args = $.extend(true, {}, _defaultOptions, options,
      	{
      	  type: "POST", cache: false,
          data: { text: text },
          dataType: 'json'
        }
      );
      
      $.each(["picture", "audio", "file"], function(_, prop) {
        if (options[prop]) {
          _args.data[ prop + "Id" ] = options[prop].id;
        }
      });

      var _url = "/talk/sessions/" + session_id + "/messages.json";
      return API._request(_url, _args, context.talkTo);
    };
    
    API._wrap(this.talkTo);
    
    // 发送私信
    this.talkTo2 = function (session_id, text, options) {
      var _args = $.extend(true, {}, _defaultOptions, options,
      	{
      	  type: "POST", cache: false,
          data: {
            text: text
          },
          dataType: 'json'
        }
      );
      
      $.each(["picture", "audio", "file"], function(_, prop) {
        if (options[prop]) {
          _args.data[ prop + "Id" ] = options[prop].id;
        }
      });

      var _url = "/talk/sessions/" + session_id + "/messages/rt_create.json";
      return API._request(_url, _args, context.talkTo2);
    };

    API._wrap(this.talkTo2);
    
    this.pullSessionChanges = function() {
      //
      var _args = $.extend(true, {}, _defaultOptions,
      	{
      	  type: "GET",
      	  cache: false,
          dataType: 'json'
        }
      );

      var _url = "/talk/sessions/pull.json";
      return API._request(_url, _args, context.pullSessionChanges);
    };
    
    API._wrap(this.pullSessionChanges);
    
    this.deleteMessage = function(id, options) {
      var _config = $.extend(true, {}, options, {
        type: 'DELETE'
      });

      return API._request('/talk/messages/' + id + ".json", _config, context.deleteMessage);
    };
    
    this.createSession = function(members, options) {
      var _args = $.extend(true, {}, _defaultOptions, options,
      	{
      	  type: "POST", cache: false,
          data: {
            members: members,
            topic: options.topic
          },
          dataType: 'json'
        }
      );

      return API._request("/talk/sessions.json", _args, this.createSession);
    };
    
    this.deleteSession = function(id, options) {
      var _config = $.extend(true, {}, options, {
        type: 'DELETE'
      });

      return API._request('/talk/sessions/' + id + ".json", _config, context.deleteSession);
    };
    
    this.sessionMembers = function(session_id, options) {
      var _args = $.extend(true, {}, _defaultOptions, options,
      	{
      	  type: "GET",
      	  cache: false,
          dataType: 'json'
        }
      );
      var _url = "/talk/sessions/" + session_id + "/members.json";
      return API._request(_url, _args, context.addSessionMembers);
    };
    
    this.addSessionMembers = function(session_id, members, options) {
      var _args = $.extend(true, {}, _defaultOptions, options,
      	{
      	  type: "POST",
      	  cache: false,
          data: {
            members: members
          },
          dataType: 'json'
        }
      );
      var _url = "/talk/sessions/" + session_id + "/members/add.json";
      return API._request(_url, _args, context.addSessionMembers);
    };
    
    // 删除成员
    this.removeSessionMember = function(session_id, member_id, options) {
      var _args = $.extend(true, {}, _defaultOptions, options,
      	{
      	  type: "DELETE",
      	  cache: false,
          data: {
            member_id: member_id
          },
          dataType: 'json'
        }
      );
      var _url = "/talk/sessions/" + session_id + "/members/" + member_id + ".json";
      return API._request(_url, _args, context.addSessionMembers);
    };
    
    this.getSession = function(session_id, options) {
      var _args = $.extend(true, {}, options, _defaultOptions,
      	{
      	  type: "GET",
      	  cache: false,
          dataType: "json"
        }
      );
      return $.ajax("/talk/sessions/" + session_id + ".json", _args);
    };
    
    this.fetchSessions = function(options) {
      var _args = $.extend(true, {}, options, _defaultOptions,
      	{
      	  type: "GET",
      	  cache: false,
          dataType: 'json'
        }
      );
      return $.ajax("/talk/sessions/fetch.json", _args);
    };
    
    this.fetchUnreadMessages = function(session_id, options) {
      var _args = $.extend(true, {}, options, _defaultOptions,
      	{
      	  type: "GET",
      	  cache: false,
      	  data: {
      	    reset_unread_count: !!options.reset_unread_count
      	  },
          dataType: 'json'
        }
      );
      return $.ajax("/talk/sessions/" + session_id + "/messages/unreads.json", _args);
    };
    
    this.resetUnreadCount = function(session_id, options) {
      var _args = $.extend(true, {}, options, _defaultOptions,
      	{
      	  type: "POST",
      	  cache: false,
          dataType: 'json'
        }
      );
      return $.ajax("/talk/sessions/" + session_id + "/messages/reset_unread_count.json", _args);
    };
    
    this.makeCurrent = function(session_id, options) {
      var _args = $.extend(true, {}, options, _defaultOptions,
      	{
      	  type: "POST",
      	  cache: false,
          dataType: 'json'
        }
      );
      return $.ajax("/talk/sessions/" + session_id + "/make_current.json", _args);
    };
    
    this.clearCurrent = function(options) {
      var _args = $.extend(true, {}, options, _defaultOptions,
      	{
      	  type: "DELETE",
      	  cache: false,
          dataType: 'json'
        }
      );
      return $.ajax("/talk/sessions/clear_current.json", _args);
    };
    
    this.fetchUnreadCount = function(session_id, options) {
      var _args = $.extend(true, {}, options, _defaultOptions,
      	{
      	  type: "GET",
      	  cache: false,
          dataType: 'json'
        }
      );
      return $.ajax("/talk/sessions/" + session_id + "/messages/unread_count.json", _args);
    };
  };
})(jQuery);
