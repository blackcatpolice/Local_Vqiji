// require jquery
// require jquery.ui.widget
// require API
// require jquery.spin

//= require libs/bootstrap-datetimepicker

(function($) {
	// Picker object
	var Calendar = function(options){
		this.widget = $(DPGlobal.template)
		  .on("click", ".prev", $.proxy(this._onPrevClick, this))
		  .on("click", ".next", $.proxy(this._onNextClick, this))
		  .on("click", ".day", $.proxy(this._onDayClick, this));

    this.container = this.widget.find('.calendar-days');
    this.format = DPGlobal.parseFormat('yyyy-mm-dd');
		this.minViewMode = 0;
    this.viewMode = 0;
    this.startViewMode = this.viewMode;
		this.weekStart = 0;
		this.weekEnd = 6;
		this.update();
	};
	
	Calendar.prototype = {
		constructor: Calendar,
		
		setValue: function(newDate) {
			if (typeof newDate === 'string') {
				this.date = DPGlobal.parseDate(newDate, this.format);
			} else {
				this.date = new Date(newDate);
			}
			this.set();
			this.viewDate = new Date(this.date.getFullYear(), this.date.getMonth(), 1, 0, 0, 0, 0);
			this.fill();
		},
		
		update: function(newDate){
		  if (newDate) {
			  this.date = DPGlobal.parseDate(newDate, this.format);
			} else {
			  this.date = new Date();
			  
			  this.date.setHours(0);
			  this.date.setMinutes(0);
			  this.date.setSeconds(0);
			  this.date.setMilliseconds(0);
			}
			this.viewDate = new Date(this.date.getFullYear(), this.date.getMonth(), 1, 0, 0, 0, 0);
			this.fill();
		},
		
		fill: function() {
			var d = new Date(this.viewDate),
				year = d.getFullYear(),
				month = d.getMonth(),
				currentDate = this.date.valueOf();

			this.widget.find('.switch').text(year + '年' + DPGlobal.dates.months[month]);

			var prevMonth = new Date(year, month-1, 28,0,0,0,0),
				day = DPGlobal.getDaysInMonth(prevMonth.getFullYear(), prevMonth.getMonth());
			prevMonth.setDate(day);
			prevMonth.setDate(day - (prevMonth.getDay() - this.weekStart + 7)%7);

			var nextMonth = new Date(prevMonth);
			nextMonth.setDate(nextMonth.getDate() + 42);
			nextMonth = nextMonth.valueOf();
			
			var html = [];
			var clsName, prevY, prevM;
			
			while(prevMonth.valueOf() < nextMonth) {
				clsName = '';
				prevY = prevMonth.getFullYear();
				prevM = prevMonth.getMonth();
				if ((prevM < month &&  prevY === year) ||  prevY < year) {
					clsName += ' old gray';
				} else if ((prevM > month && prevY === year) || prevY > year) {
					clsName += ' new gray';
				}
				if (prevMonth.valueOf() === currentDate) {
					clsName += ' on';
				}
				html.push('<li class="day '+clsName+'" data-date="' + DPGlobal.formatDate(prevMonth) + '">' + prevMonth.getDate() + '</li>');
				prevMonth.setDate(prevMonth.getDate()+1);
			}

			this.container.empty().append(html.join(''));
			this._loadMonthCount(this.viewDate);
		},
		
		_loadMonthCount: function(month) {
			if (this._countTodosByMonthRequest) {
			  this._countTodosByMonthRequest.abort();
			}
			
			var self = this;
	    this.container.spin("small");
	    var monthStr = DPGlobal.formatDate(month, DPGlobal.parseFormat("yyyy/mm"));

      // 获取任务统计
			this._countTodosByMonthRequest = Calendar.api.countTodosByMonth(monthStr, {
			  success: function(count) {
			    $.each(count, function(date, count) {
			      self.setTodoCount(date, count);
			    });
			  }/*,
			  error: function(jqXHR , textStatus, errorThrown) {
			    if (textStatus !== "abort") {
			      $.alert("获取任务日历数据失败！", 2);
			    }
			  }*/,
			  complete: function() {
			    self._countTodosByMonthRequest = null;
			    self.container.spin(false);
			  }
			});
		},
		
		setTodoCount: function(date, count) {
      var elem = this.container.find(".day[data-date="+ date +"]");
      if (count.count > 0) {
        elem
          .find("> span").remove().end()
          .data("schedule-todo-count", count)
          .attr("title", date + " 有 " + count.count + " 个待办事项");

        if (count.count > count.sys) {
          if (count.sys > 0) { // 有用户和系统待办事项
            elem.append("<span class=\"sys\"></span>");
          }

          elem.append("<span class=\"user\"></span>");
        } else { // 仅有系统待办事项
          elem.append("<span class=\"sys\"></span>");
        }
      } else {
        elem
          .removeAttr("data-todos-count")
          .attr("title", "没有待办事项")
          .find("> span").remove();
      }
		},
		
		incTodoCount: function(date, step, isSys) {
		  var elem = this.container.find(".day[data-date=" + date + "]")
		    , count = elem.data("schedule-todo-count") || { count: 0, sys: 0 };
		  count.count += step;
		  if (isSys) {
		    count.sys += step;
		  }
      this.setTodoCount(date, count);
		},
		
		reloadTodosCount: function() {
		  this._loadMonthCount(this.date);
		},
		
		_onPrevClick: function() {
		  this.viewDate.setMonth(this.viewDate.getMonth(this.viewDate) + -1);
		  this.fill();
		},
		
		_onNextClick: function() {
		  this.viewDate.setMonth(this.viewDate.getMonth(this.viewDate) + 1);
		  this.fill();
		},
		
		_onDayClick: function(e) {
		  var target = $(e.target);
		  var day = parseInt(target.text(), 10) || 1;
			var month = this.viewDate.getMonth(), newMonth = month;
			var year = this.viewDate.getFullYear();
			
			if (target.is('.old')) {
				newMonth -= 1;
			} else if (target.is('.new')) {
				newMonth += 1;
			} else {
			  target
			    .closest("ul")
			      .find(".day").removeClass("on").end()
			    .end()
			    .addClass("on");
			}
			
		  this.date = new Date(year, newMonth, day, 0,0,0,0);
		  this.viewDate = new Date(year, newMonth, Math.min(28, day), 0,0,0,0);
		  
		  this.widget.trigger("daychecked", [this.date]);
		  
		  if (newMonth != month) {
		    this.fill();
		  }
		}
  };
	
	Calendar.api = {
	  countTodosByMonth: function(monthStr, options) {
	    var _options = $.extend(true, {}, API.defaultOptions, options, {
	      method: "GET",
	      dataType: "json"
	    });
	    return API._request("/schedule/" + encodeURIComponent(monthStr) + "/todos/count.json", _options, Calendar.api.countTodosByMonth);
	  }
	};
	
	var DPGlobal = {
		dates:{
			months: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
		},
		isLeapYear: function (year) {
			return (((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0))
		},
		getDaysInMonth: function (year, month) {
			return [31, (DPGlobal.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]
		},
		parseFormat: function(format){
			var separator = format.match(/[.\/\-\s].*?/),
				parts = format.split(/\W+/);
			if (!separator || !parts || parts.length === 0){
				throw new Error("Invalid date format.");
			}
			return {separator: separator, parts: parts};
		},
		defaultFormat: {
	    separator: "-",
	    parts: ["yyyy", "mm", "dd"]
		},
		parseDate: function(date, format) {
		  format = format || format;
			var parts = date.split(format.separator),
				date = new Date(),
				val;
			date.setHours(0);
			date.setMinutes(0);
			date.setSeconds(0);
			date.setMilliseconds(0);
			if (parts.length === format.parts.length) {
				var year = date.getFullYear(), day = date.getDate(), month = date.getMonth();
				for (var i=0, cnt = format.parts.length; i < cnt; i++) {
					val = parseInt(parts[i], 10)||1;
					switch(format.parts[i]) {
						case 'dd':
						case 'd':
							day = val;
							date.setDate(val);
							break;
						case 'mm':
						case 'm':
							month = val - 1;
							date.setMonth(val - 1);
							break;
						case 'yy':
							year = 2000 + val;
							date.setFullYear(2000 + val);
							break;
						case 'yyyy':
							year = val;
							date.setFullYear(val);
							break;
					}
				}
				date = new Date(year, month, day, 0 ,0 ,0);
			}
			return date;
		},
		formatDate: function(date, format) {
			var val = {
				d: date.getDate(),
				m: date.getMonth() + 1,
				yy: date.getFullYear().toString().substring(2),
				yyyy: date.getFullYear()
			};
			val.dd = (val.d < 10 ? '0' : '') + val.d;
			val.mm = (val.m < 10 ? '0' : '') + val.m;
			var date = [];
			
			format = format || this.defaultFormat;
			
			for (var i=0, cnt = format.parts.length; i < cnt; i++) {
				date.push(val[format.parts[i]]);
			}
			return date.join(format.separator);
		},
		
		template: ''+
		  '<div>'+
			  '<div class="bk_t mr_t3 head">' +
			    '<a href="javascript:void(0)" class="prev" title="上个月">&lsaquo;</a>' +
			    '<a href="javascript:void(0)" class="rl_date switch"></a>' +
			    '<a href="javascript:void(0)" class="next" title="下个月">&rsaquo;</a>' +
			  '</div>' +
        '<div class="mr_rl f13 left">' +
		      '<ul>' +
		        '<li>周日</li>' +
		        '<li>周一</li>' +
		        '<li>周二</li>' +
		        '<li>周三</li>' +
		        '<li>周四</li>' +
		        '<li>周五</li>' +
		        '<li>周六</li>' +
          '</ul>' +
		    '</div>' +
		    '<div class="mr_rl mr_rlk f12 left">' +
		      '<ul class="calendar-days">' +
          '</ul>' +
		    '</div>' +
		  '</div>'
	};
	
	$.widget("schedule.newScheduleTodoForm", $.rtext.rtextEditor, {
	  options: {
	    tools: [] /* 禁用所有工具 */
	  },
	  
	  _getCreateOptions: function() {
	    return {
	      submit: this._submit,
	      date: new Date() // now
	    };
	  },
	  
	  _create: function() {
	    this._super();
	    this._atPicker = this.element.find(".at-picker")
	      .datetimepicker({
          startDate: this.options.date,
          endDate: new Date(this.options.date.getFullYear(),
            this.options.date.getMonth(), this.options.date.getDate(),
            23, 59, 59) // end of this day
        });
	    this._atPickerInput = this.element.find(".todo-at").placeholder();
	  },
	  
	  _destroy: function() {
	    this._super();
      this._atPicker.datetimepicker("remove");
	  },
	  
	  _submit: function(text, done) {
	    var self = this, _at = this._atPickerInput.val();

	    if ($.trim(_at) == "") {
	      /* FIXED: picker 显示在 modal-backdrop 下方 */
	      done();
	      setTimeout(function() {
          self._atPicker.datetimepicker("show");
        }, 50);
	      return;
	    }
	    
	    this._atPicker.datetimepicker("hide");
	    
	    api.createTodo(text, _at, {
	      success: function(todo) {
	        self.reset();
	        done();
	        self._trigger("created", null, todo);
	      },
	      error: function() {
	        done();
	        App.error.handleXHRError.apply(self, arguments);
	      }
	    });
	  }
	});
	
	$.widget("schedule.newScheduleTodoDialog", {
	  options: {
	    autoOpen: true/*,
	    formOptions: {}*/
	  },
	  
	  _create: function() {
	    this._form = this.element.find(".new-schedule-todo-form")
	      .newScheduleTodoForm(this.options.formOptions);

	    this._on(this.element, {
	      show: this._onModalShow,
	      hidden: this._onModalHidden
	    });
	  },
	  
	  _onModalShow: function() {
	    this._trigger("open");
	  },
	  
	  _onModalHidden: function() {
	    this._trigger("close");
	  },
	  
	  _init: function() {
	    if (this.options.autoOpen) {
	      this.open();
	    }
	  },
	  
	  _destroy: function() {
	    this._off(this.element, "shown");
	    this._off(this.element, "hidden");
	    this._form.newScheduleTodoForm("destroy");
	    this._form = null;
	  },
	  
	  open: function() {
	    this.element.modal("show");
	    return this;
	  },
	  
	  close: function() {
	    this.element.modal("hide");
	    return this;
	  }
	});
	
	$.schedule.newScheduleTodoDialog.create = function(options) {
	  var widget = $($.schedule.newScheduleTodoDialog.template)
	    .newScheduleTodoDialog(options)
	    .bind("newscheduletododialogclose", function() {
	      widget.remove();
	    });
	  return widget;
	};
	
	$.schedule.newScheduleTodoDialog.template = ''
	  + '<div class="modal schedule-calendar-modal">'
      + '<div class="modal-header">'
        + '<a class="close" data-dismiss="modal"></a>'
        + '<div class="model_tabs">创建待办事项</div>'
      + '</div>'
      + '<div class="modal-body">'
        + '<div class="modal_form">'
          + '<div class="wd_zf new-schedule-todo-form">'
            + '<div class="wd_zf_k wd_wb">'
              + '<span class="right remain_counter"></span>'
              + '<textarea class="texter" placeholder="请输入"></textarea>'
            + '</div>'
            + '<div class="input-append date at-picker" data-start-view="1" data-max-view="1" data-min-view="0" data-date-autoclose="true" data-picker-position="bottom-left" data-css-position="fixed" data-css-z-index="1060" data-date-format="yyyy-mm-dd hh:ii">'
              + '<label>提醒时间：</label>'
              + '<input type="text" class="todo-at" readonly="readonly">'
              + '<span class="add-on"><i class="icon-th"></i></span>'
            + '</div>'
            + '<div class="modal-footer f_center">'
              + '<a href="javascript:void(0)" class="btn_red submiter">创建待办事项</a>'
            + '</div>'
          + '</div>'
        + '</div>'
      + '</div>'
	  + '</div>';

  $.widget("schedule.scheduleCalendar", {
    _create: function() {
      this.element.html(''
        + '<div class="bk_c schedule-calendar">'
          + '<div class="mr_rt left f15">'
            + '<span class="title"></span>'
            + '<a class="btn btn-warning bn f12 new-btn" href="javascript:void(0)" title="新建待办事项">+ 新建</a>'
          + '</div>'
          + '<div class="mr_rrz left f12"></div>'
          + '<div class="clearfix"></div>'
        + '</div>'
        + '<div class="bk_t bk_d"></div>');

      this._calendar = (new Calendar());
      this.element.find(".bk_c").prepend(this._calendar.widget);
      
      this._on(this._calendar.widget, { daychecked: this._onDayChecked });
      this._on(this.element.find(".mr_rrz"), { "click [data-action=delete-schedule-todo]" : this._deleteTodo });
      this._on(this.element, { "click .new-btn": this._onNewBtnClick });
      
      this._showDay(this._calendar.date);
    },
    
    _deleteTodo: function(e) {
      var self = this;
      var widget = $(e.target).closest("[data-id]");
        api.deleteTodo(widget.attr("data-id"), {
          success: function() {
            widget.remove();
            self._calendar.incTodoCount(DPGlobal.formatDate(self._currentDay), -1, widget.is("[is-sys=true]"));
            if (widget.siblings().length == 0) {
              self._showDay(self._currentDay, true);
            }
          },
          error: App.error.handleXHRError
        });
    },
    
    _destroy: function() {
      this._calendar.widget.remove();
      this._calendar = null;
    },
    
    _onDayChecked: function(e, date) {
      this._showDay(date);
    },
    
    _onNewBtnClick: function() {
      var self = this, _dialog;
      _dialog = $.schedule.newScheduleTodoDialog.create({
        formOptions: {
          date: self._currentDay,
          created: function() {
            _dialog.hide();
            setTimeout(function() {
              _dialog.newScheduleTodoDialog("close");
            }, 0);
            self._calendar.incTodoCount(DPGlobal.formatDate(self._currentDay), 1);
            self.reloadDay();         
          }
        }
      });
    },
    
    reloadDay: function() {
      this._showDay(this._currentDay, true);
      return this;
    },
    
    _showDay: function(date, force) {
      if (force || (!sameDay(this._currentDay, this._calendar.date))) {
        var self = this;
        var container = this.element.find(".mr_rrz").spin("small");
        container.load("/schedule/" + encodeURIComponent(DPGlobal.formatDate(date, DPGlobal.parseFormat("yyyy/mm/dd"))) + '/todos',
          function(responseText, textStatus, XMLHttpRequest) { // complete
            if (textStatus === "success") {
              self._setTitle(date);
              self._currentDay = date;
            }
            container.spin(false);
          });
      }
    },
    
    _setTitle: function(date) {
      var today = new Date(), prefix;
      if (sameDay(date, today)) {
        prefix = "今日";
      } else {
        prefix = DPGlobal.formatDate(date, DPGlobal.parseFormat("yyyy/mm/dd")) + " ";
      }
      this.element.find(".mr_rt .title").text(prefix + "待办事项");
    }
  });
  
  var api = {
	  deleteTodo: function(id, options) {
	    var _options = $.extend(true, {}, API.defaultOptions, options, {
	      method: "DELETE",
	      dataType: "json"
	    });
	    return API._request("/schedule/todos/" + id + ".json", _options, api.deleteTodo);
	  },
	  createTodo: function(detail, at, options) {
	    var _options = $.extend(true, {}, API.defaultOptions, options, {
	      method: "POST",
	      dataType: "json",
	      data: {
	        todo: {
	          detail: detail,
	          at: at
	        }
	      }
	    });
	    return API._request("/schedule/todos.json", _options, api.createTodo);
	  }
  };
  
  function sameDay(date1, date2) {
    return (date1 === date2) || (
        (date1 && date2) &&
          (
               ( date1.getFullYear() === date2.getFullYear() )
            && ( date1.getMonth() === date2.getMonth() )
            && ( date1.getDate() === date2.getDate() )
          )
      );
  }
  
  $(document).ready(function() {
    $("#schedule-calendar-widget").scheduleCalendar();
  });
})(jQuery );
