// require weibo

// 收藏文件
$(function() {
	var menu = $('<div id="tweet-attachments-menu" class="fj_tlb">' +
			'<a href="javascript:void(0)" data-action="collect" title="收藏到网盘">收藏</a>' +  
			'<a href="javascript:void(0)" data-action="download" data-skip-pjax title="下载文件">下载</a>' +  
		'</div>');
	
	menu.hover(function(){
		$(this).show();
	}, function(){
		$(this).hide();
	});

	menu.on("click", "[data-action=collect]", function(e){
		WEIBO.collectFile(menu.attr('data-id'), {
			success: function(data){
				$.alert("已收藏到个人网盘!", 1);
			},
			error: WEIBO.ui.errorHandler
		});
	});

	$(document).on({
    mouseenter: function(e) {
      var self = $(e.target);
		  menu.css({
			  'position': 'absolute', 
			  'top': (e.target.offsetTop + 20), 
			  'left': e.target.offsetLeft, 
			  'display': 'block'
		  }).attr({
			  'data-id': self.attr('data-id')
		  })
		  .find('[data-action=download]').attr("href", self.attr("href")).end()
		  .appendTo("body");
	  },
	  mouseleave: function() {
		  menu.hide();
	  }
	}, "[data-role=rtext-attachments] [data-type=file]>a");
});
