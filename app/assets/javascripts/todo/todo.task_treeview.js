;(function($) {

function createChild(parent, container) {
  var current = $.tmpl(''
    + '<li data-task-id="${id}">'
      + '<span>'
        + '<a href="${url}" class="${classes}" target="_blank"data-skip-pjax >${title}${ (children_count > 0) ? "»" : null }</a>'
        + '<br/> 创建人：${creator} 负责人：${executor}'
      + '</span>'
    + '</li>'
  + '', this).appendTo(parent);

  if (this.expanded) {
	  current.add( current.parentsUntil(container, "li") ).addClass("open");
  }
  
  if ((this.children_count > 0)) {
	  current.children("span").addClass("folder");
    var branch = $("<ul></ul>").appendTo(current);
	    
	  if (this.children && this.children.length) {
	    $.each(this.children, function(_, child) {
	      createChild.call(child, branch, container);
	    });
	  } else {
	    current.addClass("has-more-children")
	  }
  } else {
	  current.children("span").addClass("file");
  }
  return current;
}

function load(url, parent, container) {
	$.ajax({
		url: url,
		dataType: "json",
		success: function(task) {
		  parent.empty();
		  $.each([ task ], function(_, child) {
			  createChild.call(child, parent, container);
			});
      container.treeview({ add: parent });
    }
	});
}

function loadChildren(id, parent, container) {
	$.ajax({
		url: "/todo/tasks/" + id + "/subs/treeview.json",
		dataType: "json",
		success: function(children) {
		  parent.empty();
		  $.each(children, function(_, child) {
			  createChild.call(child, parent, container);
			});
      container.treeview({ add: parent });
    }
	});
}

var treeview = $.fn.treeview;

$.fn.todoTaskTreeview = function(id) {
	var container = this;
	if (!container.children().size()) {
		load("/todo/tasks/" + id + "/treeview.json", this, container);
	}
	container.treeview({
		collapsed: true,
		toggle: function() {
			var self = $(this);
			if (self.is(".has-more-children")) {
				var children = self.removeClass("has-more-children").find("ul");
				var branchId = self.data("task-id");
				loadChildren(branchId, children, container);
			}
		}
	});
	return this;
};

})(jQuery);
