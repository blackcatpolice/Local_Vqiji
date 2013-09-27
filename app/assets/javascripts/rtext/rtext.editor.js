// 富文本编辑器的逻辑抽象
//
// 封装了一下工作能逻辑
// 1. 验证
//   * 空文本域验证（闪动提示）
//   * 最大字数验证（闪动提示）
// 2. 剩余字数显示
// 3. 文字操作
//   * 追加
//   * 插入
// 4. 提到输入提示
// 5. 工具栏
//   * 表情
//
// require jquery
// require jquery.blink
// require jquery.jquery.atwho
// require rtext.texter
// require rtext.remain_counter
// require rtext.attachments
// require rtext.emotion.picker
//
// 请在以下结构上扩展
//
// <div class="rtext_editor">
//   <span class="remain_counter" /><br />
//   <textarea class="texter" /><br />
//   <div class="toolbar"></div>
//   <input type="button" class="submiter" value="提交" />
// </div>
//
//
// </div>

(function($) {
  "use strict";

  $.widget("rtext.rtextEditor", {
    options: {
      allowBlank: false,
      textMaxLength: 140,
      tools: ["emotion"],  /* 使用的工具 */
      inputMention: false, /* 可否输入 mention */
      preset: null,
      placeHolder: null,
      submit: null,
      toolbarOptions: null,
      remainCounterOptions: null
    },

    _create: function() {
      // 文本编辑框
      this._texter = this.element.find(".texter")
        .rtextTexter({
          preset: this.options.preset,
          placeHolder: this.options.placeHolder
        });

      // 剩余字数提示
      this._remainCounter = this.element.find(".remain_counter")
        .rtextRemainCounter($.extend(true, {
          target: this._texter,
          maxLength: this.options.textMaxLength
        }, this.options.remainCounterOptions));

      // 提到（@）输入
      if (this.options.inputMention) {
        this._enableMention();
      }

      // @工作组成员
      if (this.options.groupMention) {
        this._enableGroupMention();
      }

      // 工具栏
      this._toolbar = this.element.find(".toolbar")
        .toolbar(this.options.toolbarOptions).hide();

      // 启用预置工具
      if (this.options.tools && (this.options.tools.length > 0)) {
        $.each(this.options.tools,
          $.proxy(function(_, tool) {
            this._initTools(tool)
          }, this));
        this._toolbar.fadeIn("slow");
      }
      
      this._submiter = this.element.find(".submiter");
      this._on(this._submiter, { click: this.submit });
    },

    reset: function() {
      this._texter.rtextTexter("reset");
      this._toolbar.toolbar("closeAllTools");

      if (this._pictureUploader) {
        this._pictureBtn.removeClass("on");
        this._pictureUploader.pictureUploader("reset");
      }

      if(this._fileUploader){
        this._fileBtn.removeClass("on");
        this._fileUploader.fileUploader("reset");
      }
      
      if(this._chooseFiles){
      	this._fileBtn.removeClass("on");
      	this._chooseFiles.chooseFile('reset');
      }
      
      if((this._fileUploader || this._chooseFiles) && this._selecedFileText){
      	this._selecedFileText.text("").hide();
      }
      
      if(this._audioRecorder) {
        if (this._audioBtn) {
          this._audioBtn.removeClass("on");
        }
        this._audioRecorder.audioRecorder("reset");
      }
      
      this.resetBigAudionButton();
      this._remainCounter.rtextRemainCounter("reset");

      this._picture = null;
      this._audio = null;
      this._file = null;
      this._selectedFile = null;

      return this;
    },

    resetBigAudionButton: function() {
      if(this.bigAudioBtn) {
        this.bigAudioBtn.find("a").text("");
        this.bigAudioBtn.parent().removeClass("dhk1");
      }
    },

    _init: function() {
      this.reset();
    },

    _setOption: function(key, value) {
      if (key === "textMaxLength") {
        this._remainCounter.rtextRemainCounter("option", key, value);
      } else if (key === "preset" || key === "placeHolder") {
        this._texter.rtextTexter("option", key, value);
      }
      return this._superApply([key, value]);
    },

    disable: function() {
      // 将文本 texter 和 提交按钮一起禁用
      this._texter.rtextTexter("disable");
      this._submiter.attr("disabled", "disabled");
      return this._super();
    },

    enable: function() {
      this._submiter.removeAttr("disabled");
      this._texter.rtextTexter("enable");
      return this._super();
    },

    _destroy: function() {
      this._off(this._submiter, "click");
      this._remainCounter.rtextRemainCounter("destroy");
      this._texter.rtextTexter("destroy");
      this._toolbar.toolbar("destroy");
    },

    texter: function(text) {
      return this._texter;
    },

    text: function(text) {
      if (arguments.length == 1) {
        this._texter.rtextTexter("text", text);
        this._remainCounter.rtextRemainCounter("update");
        return this;
      }
      return this._texter.rtextTexter("text");
    },

    // 追加文字
    textAppend: function(text) {
      this._texter.rtextTexter("append", text);
      this._remainCounter.rtextRemainCounter("update");
      return this;
    },

    //
    // FIXME: 当在ajax请求中访问 selection 时发生 800a025e 错误
    // FIXED: 重新开启一个普通线程来执行 selection 相关操作
    _texterCall: function(func) {
      var proxy = $.proxy(func, this);
      setTimeout(proxy);
    },

    // 在光标所在处插入文字
    textInsert: function(text) {
      var range = this._texter.rtextTexter("insert", text);
      this._remainCounter.rtextRemainCounter("update");
      return range;
    },

    // 前置文字
    textPreppend: function(text) {
      this._texterCall(function() {
        this._texter.rtextTexter("preppend", text);
        this._remainCounter.rtextRemainCounter("update");
      });
      return this;
    },

    // 插入表情
    insertEmotion: function(emotion) {
      this._texterCall(function() {
        this.textInsert("[" + emotion + "]");
      });
      return this;
    },

    // 插入提到
    insertMention: function(name) {
      this._texterCall(function() {
        this.textInsert("@" + name + " ");
      });
      return this;
    },

    // 插入话题
    // select：是否选中
    insertTopic: function(title, select) {
      this._texterCall(function() {
        var range = this.textInsert("#" + title + "#");
        if (select) {
          this._texter.rtextTexter("select", range[0] + 1, range[1] - 1);
        }
      });
      return this;
    },
    
    _enableMention: function() {
      this._texter.atwho({
        at: "@",
        limit: 7,
        callbacks: {
          remote_filter: function(query, callback) {
            WEIBO.api.queryFolloweds({
              async: false,
              page: 1,
              psize: 7,
              query: query,
              cache: true,
              success: function(data) {
                callback(data);
              }
            });
          }
        },
        tpl: '<li data-value="${name}">${name}</li>',
        start_with_space: false
      });
    },
    
    _enableGroupMention: function() {
      this._texter.atwho({
        at: "@",
        limit: 7,
        callbacks: {
          remote_filter: function(query, callback) {
            WEIBO.api.queryGroups({
              async: false,
              page: 1,
              psize: 7,
              query: query,
              cache: true,
              success: function(data) {
                callback(data);
              }
            });
          }
        },
        tpl: "<li id='${id}' data-value='${nickname}'>${nickname}</li>",
        start_with_space: false
      });
    },

    _initBigAudio:function() {
       var context = this;
        var bigAudioButton = $('div[data-type="audio-button"]',this.element);
        
        //alert(bigAudioButton.length);
        if(bigAudioButton.length > 0) {
          context.bigAudioBtn = $(bigAudioButton[0]);
          $(context.bigAudioBtn).click(function() {
            context._toolbar.toolbar("closeAllTools");
            if(context._audioRecorder == null) {
              context._audioRecorder = 
                $('<div class="tip-audio-recorder" />').audioRecorder({
                  autoOpen: false,
                  uploadSuccess: function(event, data) {
                    context._audio = data.audio;
                    if(context.bigAudioBtn){
                      context.bigAudioBtn.parent().addClass("dhk1");
                      $("a",context.bigAudioBtn).text(context._audio.duration+"″");
                    }
                    /* if ( context._isSupportTopic() ) {
                      context.insertTopic("分享语音");
                    } */
                  },
                  deleted: function() {
                    context._audio = null;
                    context.resetBigAudionButton();
                  },
                  done: function() {
                    context._audioRecorder.tip("close");
                  }
                 });
              context._audioRecorder
                .tip($.extend(true, {}, 
                              context.options.toolbarOptions && context.options.toolbarOptions.tip, {
                              trigger: context.bigAudioBtn,
                              triggerEvents: null,
                              autoOpen: true,
                              tipClass: "tip-audio-recorder-tip-class"
                            }));
            } else {
              context._audioRecorder.tip("open");
            }
          });
        }
    },

    /* 语音 */
    _loadAudioTool:function(audioBtn){
      var context = this;
      this._toolbar.toolbar("addTool", audioBtn, function() {
      var _tipContent = $("<div class=\"tip-audio-recorder\" />").audioRecorder({
          autoOpen: false,
          uploadSuccess: function(event, data) {
            context._audio = data.audio;  /* _tipContent.audioRecorder("id");*/
            if(context.bigAudioBtn){
              context.bigAudioBtn.parent().addClass("dhk1");
              $("a", context.bigAudioBtn).text(context._audio.duration + "″");
            }
            /*if ( context._isSupportTopic() ) {
              context.insertTopic("分享语音");
            }*/
            audioBtn.addClass("on");
          },
          deleted: function() {
            context._audio = null;
            context.resetBigAudionButton();
            audioBtn.removeClass("on");
          },
          done: function() {
            context._toolbar.toolbar("triggerTool", audioBtn, "close");
          }
         });
         context._audioRecorder = _tipContent;
         return _tipContent;
      }, {
        tipClass: "tip-audio-recorder-tip-class"
      });
      
      this._audioBtn = audioBtn;
    },

    /* 表情 */
    _loadEmotionTool:function(emotionBtn){
      var context = this;
      this._toolbar.toolbar("addTool", emotionBtn, function() {
        return $('<div class="tip-emotion-picker" />').rtextEmotionPicker({
          picked: function(event, data) {
            context.insertEmotion(data.em);
            context._toolbar.toolbar("triggerTool", emotionBtn, "close");
          }
        });
      }, {
        tipClass: "tip-emotion-picker-tip-class"
      });
    },

    /* 话题 */
    _loadTopicTool:function(topicBtn){
     var context = this;
      this._toolbar.toolbar("addTool", topicBtn, function() {
        var btn = $("<a href=\"javascript:void(0);\" class=\"add-topic-btn\">插入话题</a>")
          .click(function(){
            context.insertTopic('在这里输入话题', true);
            context._toolbar.toolbar("triggerTool", topicBtn, "close");
          });
        var _tip = $("<div class=\"tip-add-topic\"></div>").append(btn);
        return _tip;
      }, {
        tipClass: "tip-add-topic-tip-class"
      });
    },

    /* 视频 */
    _loadVideoTool:function(videoBtn){
      var context = this;
      this._toolbar
        .toolbar("addTool", videoBtn, function () {
          var _tip = $('<div></div>');
          var _installer = $('<div class="tip-video-url-installer"></div>')
            .videoURLInstaller({
              install: function(event, url) {
                // 如果支持话题，插入 #分享视频#
                /*if ( context._isSupportTopic() ) {
                  context.insertTopic("分享视频");
                }*/
                // 添加视频链接
                context.textAppend(url.shorten + " ");
                context._toolbar.toolbar("triggerTool", videoBtn, "close");
              }
            }).appendTo(_tip);
          return _tip;
        }, {
          tipClass: "tip-video-url-installer-tip-class"
        });
    },

    /* 图片 */
    _loadPictureTool: function(pictureBtn){
      var context = this;
      this._toolbar.toolbar("addTool", pictureBtn, function() {
        var _tip = $('<div class=\"tip-picture-uploader\"></div>');
        context._pictureUploader = _tip
          .pictureUploader({
            uploaded: function(event, picture) {
              context._picture = picture;
              // 如果支持话题，插入 #分享图片#
              /*if ( context._isSupportTopic() ) {
                context.insertTopic("分享图片");
              } */
              pictureBtn.addClass("on");
            },
            deleted: function() {
              context._picture = null;
              pictureBtn.removeClass("on");
            },
            finish: function() {
              context._toolbar.toolbar("triggerTool", pictureBtn, "close");
            }
          }).appendTo(_tip);
          return _tip;
        }, {
          tipClass: "tip-picture-uploader-tip-class"
        });

        this._pictureBtn = pictureBtn;
      },

    /* 附件 */
    _loadFileTool:function(fileBtn) {
      var context = this;
      this._toolbar.toolbar("addTool", fileBtn, function () {
        var _tip = $("<div style=\"height: 100%;\"></div>");
        
        // 选取文件
        $('<div class="bs-docs-example">' +
            '<ul class="nav nav-tabs">'   +
              '<li class="active"><a href="javascript:void(0)" data-role="role-upload">附件</a></li>'  +
              '<li><a href="javascript:void(0)" data-role="role-disk">网盘</a></li>' +
              '<li><a data-role="selected-file" style="display:none;cursor: text;"></a></li>' + 
            '</ul>' +
          '</div>').appendTo(_tip);
        
        $(_tip).find('a[data-role="role-upload"]').on('click', function() {
        	$('.active', _tip).removeClass('active');
        	$(this).parent().addClass('active');
        	_tip.triggerHandler("resize");
        	context._fileUploader.show();
        	context._chooseFiles.hide();
        }).end().find('a[data-role="role-disk"]').on('click', function() {
        	if(context._file){
        		$.alert('附件已上传，请删除附件后再选择网盘文件！');
        		return false;
        	}
        	$('.active', _tip).removeClass('active');
        	$(this).parent().addClass('active');
        	if(!context._chooseFiles){
	        	context._chooseFiles = $('<div class="tip-disk-choose f12" style="display:none;"></div>').chooseFile({
		        	selected: function(event, file) {
		        		context._selectedFile = file;
		        		fileBtn.addClass("on");
		        		context._selecedFileText.text("已选附件: " + $.truncate(context._selectedFile.name, 10)).show();
		        	},
		        	deleted: function() {
		        		context._selectedFile = null;
		        		fileBtn.removeClass("on");
		        		context._selecedFileText.text("").hide();
				      },
				      resize: function() {
        	      _tip.triggerHandler("resize");
				      }
	      		}).appendTo(_tip);
      		}
        	context._chooseFiles.show();
        	context._fileUploader.hide();
        	_tip.triggerHandler("resize");
        }).end();

        context._selecedFileText = $('a[data-role=selected-file]', _tip);
	      
	      // 文件上传
        context._fileUploader = $("<div class=\"tip-file-uploader\" />").fileUploader({
          uploaded: function(event, file) {
            context._file = file;
            if(context._selecedFileText){
            	context._selecedFileText.text("已选附件: " + $.truncate(file.name, 10)).show();
            }
            fileBtn.addClass("on");
          },
          deleted: function() {
            context._file = null;
            if(context._selectedFile){
              context._selecedFileText.text("已选附件: " + $.truncate(context._selectedFile.name, 10)).show();
            }else{
              if(context._selecedFileText){
              	context._selecedFileText.text("").hide();
              }
              fileBtn.removeClass("on");
            }
          },
          finish: function() {
            context._toolbar.toolbar("triggerTool", fileBtn, "close");
          }
        }).appendTo(_tip);
        return _tip;
      }, {
        tipClass: "tip-file-uploader-tip-class"
      });
      
      this._fileBtn = fileBtn;
    },

    /* 撮代码，重构！！ 兼容以前的 */
    _initTools: function(tool) {
      if (tool == "emotion") { /*表情输入*/
        var emotionButton = $('<a class="bq" href="javascript:void(0);" title="插入表情"></a>');
        this._loadEmotionTool(emotionButton);
      } else if (tool == "audio") { /*语音插入*/
      	 var audioButton = $('<a class="ly" href="javascript:void(0);" title="录制语音"></a>');
         this._loadAudioTool(audioButton);
      } else if (tool == "topic") {
      	var topicButton = $('<a class="ht" href="javascript:void(0);" title="插入话题"></a>');
        this._loadTopicTool(topicButton);
      } else if(tool == "picture") {
      	var pictureButton = $('<a class="tp" href="javascript:void(0);" title="上传图片"></a>');
        this._loadPictureTool(pictureButton);
      } else if(tool == "video") {
        var videoButton = $('<a class="sp" href="javascript:void(0);" title="插入视频"></a>');
        this._loadVideoTool(videoButton);
      } else if(tool == "file") {
         var fileButton = $('<a class="fj" href="javascript:void(0);" title="上传附件"></a>');
         this._loadFileTool(fileButton);
      } else if(tool == "bigAudio") {
        this._initBigAudio();
      }
    },
    
    // 是否支持话题输入？
    _isSupportTopic: function() {
      return ($.inArray("topic", this.options.tools) !=-1);
    },
    
    // 验证
    _validate: function(unlockIfError) {
      // 空验证
      if (!this.options.allowBlank) {
        // 文本为空
        if ($.isBlank(this._texter.val())) {
          this._texter.blink(unlockIfError);
          return false;
        }
      }

      // 最大长度验证
      if (this.options.textMaxLength > 0) {
        if (this._remainCounter.rtextRemainCounter("remainCount") < 0) {
          this._texter.blink(unlockIfError);
          return false;
        }
      }

      return true;
    },
    
    _prepareSubmit: function() {
      // 关闭所有小工具
      this._toolbar.toolbar("closeAllTools");
    },

    // 提交
    submit: function() {
      if (this._submitLocking) {
        return this;
      }

      this._submitLocking = true;
      var context = this;
      
      this._prepareSubmit();

      // 禁止用户重复提交操作
      this._submiter.attr("disabled", "disabled");
      
      /*
         验证失败并完成提示后调用解除提交锁定
       */
      var unlockIfError = function() {
        context._submiter.removeAttr("disabled");
        context._submitLocking = false;
      }
      
      if (!this._validate(unlockIfError)) {
        return false;
      }

      this.disable();

      var submitDone = function() {
        context.enable();
        context._submitLocking = false;
      };

      // 提交
      var _submit = this.options.submit || this._submit;

      if (_submit) {
        if ($.isFunction(_submit)) {
          _submit.call(this, this.text(), submitDone);
        } else {
          submitDone();
          $.error("Option '_submit' must be Function!");
        }
      } else {
        submitDone();
        $.error("Option '_submit' required!");
      }

      return this;
    }
  }); // rtextEditor
})(jQuery);
