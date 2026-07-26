<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/Board_popfun.asp -->
<!-- #include file=../User/inc/UserTopic.asp -->
<%
DEF_BBS_homeUrl="../"

Main

Sub Main

	BBS_SiteHead DEF_SiteNameString & " - 应用",0,"应用"
	UserTopicTopInfo("plug")

	If GBL_CHK_User = "" then
		Response.write "<div class=alert>您没有使用此功能的权限，请先登陆或者注册为论坛会员。</div>"
	Else
		Main_ChineseCode
	End If
	UserTopicBottomInfo
	SiteBottom

End Sub

Sub Main_ChineseCode

%>
	<script>
	var PLUG = [{
	"id":1,
	"class":0,
	"name":"汉字简体繁体转换",
	"url":"../plug-ins/ChineseCode/ChineseCode.htm",
	"width":"500px",
	"height":"400px",
	"desc":"允许即时将汉字进行简繁体转换．"
	},{
	"id":2,
	"class":0,
	"name":"万年历",
	"url":"../plug-ins/ChineseCode/cal/cal.htm",
	"width":"540px",
	"height":"475px",
	"desc":"支持农历及基本节日查看．"
	},{
	"id":3,
	"class":1,
	"name":"黄金矿工",
	"url":"../plug-ins/flash_gold/default.asp?appflag=1",
	"width":"580px",
	"height":"900px",
	"desc":"小游戏，快来创造您的挖矿记录吧．"
	},{
	"id":4,
	"name":"聊天室",
	"class":0,
	"url":"../plug-ins/bbschat/default.asp?appflag=1",
	"width":"500px",
	"height":"900px",
	"desc":"论坛专用聊天室，即时查看会员发帖及上下线等情况，允许即时文字聊天．"
	},{
	"id":5,
	"class":0,
	"name":"替文章加上拼音",
	"url":"../plug-ins/pinyin/default.htm",
	"width":"100%",
	"height":"900px",
	"desc":"允许将一篇文章加上完整的拼音，方便学习中文的朋友朗读．"
	},{
	"id":8,
	"class":0,
	"name":"论坛音乐盒",
	"url":"../app/leadbbs/default.asp",
	"width":"644px",
	"height":"450px",
	"desc":"论坛在线音乐"
	},{
	"id":9,
	"class":0,
	"name":"论坛徽章领取",
	"url":"../app/leadbbs/default.asp?file=medal",
	"width":"540px",
	"height":"420px",
	"desc":"论坛徽章领取"
	},{
	"id":13,
	"class":0,
	"name":"视频上传(优酷)",
	"url":"../app/tools/youku/default.asp",
	"width":"100%",
	"height":"750px",
	"desc":"优酷视频上传。"
	},{
	"id":15,
	"class":0,
	"name":"二维码生成",
	"url":"tools/qrcode/index.htm",
	"width":"460px",
	"height":"360px",
	"desc":"输入内容生成二维码方便手机获取"
	}];
	</script>
	<style>
	.plugClass li{display:block;float:left;
		border-radius: 6px;
		padding:8px;background:#ccc;margin-bottom:16px;margin-right:16px;
		border:1px #ccc solid;
		}
		#appmain{display:none;background:#fff;border-top:1px #888888 dashed;_border:0px #888888 dashed;float:left;padding:0px;margin-bottom:35px;}
		.plugselect{padding:0px;margin:0px;list-style:none;position:relative;}
		.plugselect .item{display:block;float:left;
		border-radius: 6px;
		padding:8px;background:#ccc;margin-bottom:16px;margin-right:16px;
		background:url(appimg/blank.png) no-repeat;
		border:1px #ccc solid;
		}
		.plugselect .item a{font-weight:normal;text-align:center;}
		.plugselect .item a span{padding-top:3px;display:block;width:124px;line-height:19px;
		overflow:hidden;height:19px;text-overflow: ellipsis;white-space:nowrap;word-wrap:normal;
		}
		.plugselect .item a img{width:124px;height:96px;}
		.plugselect .item .note{color:gray;display:block;padding-top:3px;display:none;}
		.apptitle .title{}
		.apptitle .return{float:right;padding-left:60px;color:blue;}
		.classItem{display:none;}
		.plugClass a.select{font-weight:bold;}
	</style>
	<ul class="plugClass"></ul>
	<div class="clear"></div>
	<ul class="plugselect">
	</ul>
	
	<div class="clear"></div>
		<div id="appTitle" class="apptitle" style="margin-bottom:10px;font-weight:bold;color: blue;font-size:14px;"></div>
	<div class="appmain" id="appmain" style="">
		<iframe src="" name="appFrame" id="appFrame" hidefocus="" frameborder="no" scrolling="no" style="margin:0px;padding:0px;font-size:12px;overflow-x:hidden;"></iframe>
	</div>
	<script>
	$(".tdleft").hide();
	$(".content_main_left").css("margin-right","0px");
	$(".content_main_2_left").css("margin-right","0px");
	var loadingApp = 0;
	<%
	dim id
	id = toNum(request("id"),0)
	if id > 0 Then Response.Write " loadingApp = " & id & ";" & VbCrLf
	%>
	function app_load(title,url,width,height)
	{
		$id("appFrame").contentWindow.document.write("Loading..."); 
		$("#appmain").show();
		$(".plugselect").hide();
		$(".plugClass").hide();
		$("#appTitle").show();
		$(".apptitle").width(width);
		$("#appFrame").width(width);
		$("#appFrame").css("width",width);
		$("#appFrame").css("height",height);
		$("#appmain").css("width",width);
		$("#appmain").css("height",height);
		$id("appFrame").src = url;
		$id("appTitle").innerHTML = "<span class=\"title\">"+title+"</span> <a class=\"return\" href=\"javascript:;\" onclick=\"app_return();\">返回</a> <a class=\"return\" href=\"javascript:;\" onclick=\"app_reload();\">刷新</a>";
    
		$("#appTitle").ScrollTo(500);
	}
	function app_reload()
	{
		$("#appFrame")[0].contentWindow.location.reload();
	}
	function app_return()
	{
		$("#appmain").hide();
		$(".plugselect").show();
		$("#appTitle").hide();
		$(".plugClass").show();
	}
	String.prototype.getQuery = function(name){
		var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
		var r = this.substr(this.indexOf("/?")+1).match(reg);
		if (r!=null) return unescape(r[2]); return null;
	}
	function swapclass(t)
	{
		$(".classItem").hide();
		$("#plugselect"+t).show();
		$(".plugClass a").attr("class","");
		$("#plugClickClass"+t).attr("class","select");
	}
	
	function plug_init()
	{
		plug_init_class(0,"工具",1);
		plug_init_class(1,"游戏");
	}
	function plug_init_class(t,name,v)
	{
		var cur_plug = parseInt(<%=toNum(request.querystring("id"),0)%>);
		var plug = $(".plugselect");
		$(plug).append("<div class=\"classItem\" id=\"plugselect"+t+"\"></div>");
		if(v)$("#plugselect"+t).show();
		$(".plugClass").append("<li><a id=\"plugClickClass"+t+"\" href=\"javascript:;\" onclick=\"swapclass("+t+");\">"+name+"</a></li>");
		if(v)$("#plugClickClass"+t).attr("class","select");
		for(var n=0;n<PLUG.length;n++)
		if(t==PLUG[n]["class"])$("#plugselect"+t).append("<li id=\"plugItem"+PLUG[n]["id"]+"\" class=\"item\"><a href=javascript:; onclick='app_load(\""+PLUG[n]["name"]+"\",\""+PLUG[n]["url"]+"\",\""+PLUG[n]["width"]+"\",\""+PLUG[n]["height"]+"\");'><img src=\"../images/blank.gif\" style=\"background:url('appimg/"+PLUG[n]["id"]+".png');\"><span>"+PLUG[n]["name"]+"</span></a><span class=note>"+PLUG[n]["desc"]+"</span></li>");
		if(cur_plug<1 || cur_plug>PLUG.length)cur_plug=1;
		cur_plug--;
		if(loadingApp>0)
		for(var n=0;n<PLUG.length;n++)
		{
			if(loadingApp==PLUG[n]["id"])
			{
				$("#plugClickClass"+t).click();
				$("#plugItem"+loadingApp+" a").click();
			}
		}
		//app_load(PLUG[cur_plug]["name"],PLUG[cur_plug]["url"],PLUG[cur_plug]["width"],PLUG[cur_plug]["height"]);
	}
	plug_init();
	</script>
		
<%

End Sub%>