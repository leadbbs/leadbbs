	var pi_cur = "",pi_save="";
	$(document).ready(function(){
		var c2 = $(".playimages").length,pi_count;
		for(var L=0;L<c2;L++)
		{
			var sel = ".playimages:eq(" + L + ")";
			pi_count=$(sel + ">.playimages_list a").length;
			if(!$(sel).attr('id'))
			{
				$(sel).attr('id',"playimages"+L);
				$(sel + ">.playimages_list a:not(:first-child)").hide();
				$(sel + ">.playimages_info").html($(sel + ">.playimages_list a:first-child").attr('title'));
				$(sel + ">.playimages_info").click(function(){window.open($(sel + ">.playimages_list a:first-child").attr('href'), "_blank")});
				
				$(sel + " li").click(function() {
					if($(this).attr('class')=="on")return;
					var i = $(this).text();
					if(isNaN(i))i=$(this).find("span").text();
					i = i - 1;
					var ti = this.parentNode.parentNode.id.replace(/playimages/gi,"");
					var thisi = ".playimages:eq("+ti+")";
					if (i >= pi_count) return;
					$(thisi + ">.playimages_info").html($(thisi + ">.playimages_list a").eq(i).attr('title'));
					$(thisi + ">.playimages_info").unbind().click(function(){window.open($(thisi + ">.playimages_list a").eq(i).attr('href'), "_blank")})
					$(thisi + ">.playimages_list a").filter(":visible").fadeOut(500).parent().children().eq(i).fadeIn(1000);
					$(this).toggleClass("on");
					$(this).siblings().removeAttr("class");
					pi_save = pi_save.indexOf("F" + ti+"_")!=-1?pi_save.replace((new RegExp("F"+ti+"_\\d+","gi")),"F"+ti+"_"+i):pi_save+"F"+ti+"_"+i;
				});
				if($(sel + " li").length>1)setTimeout("pi_show('" + sel + "',0," + pi_count + ")", 4000);
				$(sel).hover(function(){pi_cur=this.id;}, function(){pi_cur="";});
			}
		}
	});
	
	function pi_show(D,n,count)
	{
		if(pi_cur!=$(D).attr('id'))
		{
			var ti = $(D).attr('id'),i=-1;
			ti = ti.replace(/playimages/gi,"");
			if(pi_save.indexOf("F" + ti+"_")!=-1)
			{
				var t = pi_save.match((new RegExp("F"+ti+"_\\d+","gi")));
				if(t&&t[0])i=parseInt(t[0].replace((new RegExp("F"+ti+"_","gi")),""));
				
				pi_save = pi_save.replace((new RegExp("F"+ti+"_\\d+","gi")),"");
				if(i!=-1)n = i;
				//$(D+" li").eq(n).trigger('click');
			}
			else
			{
				n = n >=(count - 1) ? 0 : ++n;
				//$(D+" li").eq(n).trigger('click');
				
				var i = $(D+" li").eq(n).text();
				if(isNaN(i))i=$(D+" li").eq(n).find("span").text();
				i = i - 1;
				var ti = $(D).attr('id').replace(/playimages/gi,"");
				var thisi = ".playimages:eq("+ti+")";
				if (i >= count) return;
				$(thisi + ">.playimages_info").html($(thisi + ">.playimages_list a").eq(i).attr('title'));
				$(thisi + ">.playimages_info").unbind().click(function(){window.open($(thisi + ">.playimages_list a").eq(i).attr('href'), "_blank")})
				$(thisi + ">.playimages_list a").filter(":visible").fadeOut(500).parent().children().eq(i).fadeIn(1000);
				$(D+" li").eq(n).toggleClass("on");
				$(D+" li").eq(n).siblings().removeAttr("class");
			}
		}
		setTimeout("pi_show('" + D + "'," + n + "," + count + ")", 4000);
	}