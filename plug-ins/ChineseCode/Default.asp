<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../../User/inc/UserTopic.asp"-->
<%
DEF_BBS_homeUrl="../../"

Main()

Sub Main

	BBS_SiteHead DEF_SiteNameString & " - 插件",0,"<span class=navigate_string_step>插件</span>"
	UserTopicTopInfo("plug")

	If GBL_CHK_User = "" then
		Response.write "<div class=alert>您没有使用此功能的权限，请先登陆或者注册为论坛会员。</div>"
	Else
		Main_ChineseCode()
	End If
	UserTopicBottomInfo()
	SiteBottom()

End Sub

Sub Main_ChineseCode

%>
	<script>
	var PLUG = [{
	"id":1,
	"name":"汉字简体繁体转换",
	"url":"ChineseCode.htm",
	"width":"500px",
	"height":"400px",
	"desc":"允许即时将汉字进行简繁体转换．"
	},{
	"id":2,
	"name":"万年历",
	"url":"cal/cal.htm",
	"width":"540px",
	"height":"475px",
	"desc":"支持农历及基本节日查看．"
	},{
	"id":3,
	"name":"黄金矿工",
	"url":"../flash_gold/default.asp?appflag=1",
	"width":"580px",
	"height":"900px",
	"desc":"小游戏，快来创造您的挖矿记录吧．"
	},{
	"id":4,
	"name":"聊天室",
	"url":"../bbschat/default.asp?appflag=1",
	"width":"500px",
	"height":"900px",
	"desc":"论坛专用聊天室，即时查看会员发帖及上下线等情况，允许即时文字聊天．"
	},{
	"id":5,
	"name":"替文章加上拼音",
	"url":"../pinyin/default.htm",
	"width":"100%",
	"height":"900px",
	"desc":"允许将一篇文章加上完整的拼音，方便学习中文的朋友朗读．"
	}];
	</script>
	<style>
		.plugselect{padding:0px;margin:0px;list-style:none;}
		.plugselect .item{display:block;float:left;
		border-radius: 6px;
		padding:8px;background:#ccc;margin-bottom:16px;margin-right:16px;
		}
		.plugselect .item a{font-weight:normal;}
		.plugselect .item .note{color:gray;display:block;padding-top:3px;display:none;}
	</style>
	<ul class="plugselect">
	</ul>
	<div class="clear"></div>
		<div id="appTitle" class="apptitle" style="margin-bottom:10px;font-weight:bold;color: blue;font-size:14px;"></div>
	<div class="appmain" id="appmain" style="border:1px #888888 dashed;_border:0px #888888 dashed;float:left;width:300px;padding:5px;_padding:0px;margin-bottom:35px;">
		<iframe src="" name="appFrame" id="appFrame" hidefocus="" frameborder="no" scrolling="no" style="margin:0px;padding:0px;font-size:12px;overflow-x:hidden;"></iframe>
	</div>
	<script>
	function app_load(title,url,width,height)
	{
		$("#appFrame").width(width);
		$("#appmain").width(width);
		$("#appFrame").height(height);
		$("#appmain").height(height);
		$id("appFrame").src = url;
		$id("appTitle").innerHTML = title;
	}
	String.prototype.getQuery = function(name){
		var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
		var r = this.substr(this.indexOf("/?")+1).match(reg);
		if (r!=null) return unescape(r[2]); return null;
	}
	function plug_init()
	{
		var cur_plug = parseInt(<%=toNum(request.querystring("id"),0)%>);
		var plug = $(".plugselect");
		for(var n=0;n<PLUG.length;n++)
		$(plug).append("<li class=\"item\"><a href=javascript:; onclick='app_load(\""+PLUG[n]["name"]+"\",\""+PLUG[n]["url"]+"\",\""+PLUG[n]["width"]+"\",\""+PLUG[n]["height"]+"\");'>"+PLUG[n]["name"]+"</a> <span class=note>"+PLUG[n]["desc"]+"</span></li>");
		if(cur_plug<1 || cur_plug>PLUG.length)cur_plug=1;
		cur_plug--;
		app_load(PLUG[cur_plug]["name"],PLUG[cur_plug]["url"],PLUG[cur_plug]["width"],PLUG[cur_plug]["height"]);
	}
	plug_init();
	</script>
		
<%

End Sub%>