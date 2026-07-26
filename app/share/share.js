var ld_share_site={
qzone:{name:"QQ\u7a7a\u95f4",
u:"http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey"
},tsina:{name:"\u65b0\u6d6a\u5fae\u535a",
u:"http://service.weibo.com/share/share.php",
img:"searchPic"},
weixin:{name:"\u5fae\u4fe1"},tqq:{name:"\u817e\u8baf\u5fae\u535a",
u:"http://share.v.t.qq.com/index.php"},renren:{name:"\u4eba\u4eba\u7f51",
u:"http://widget.renren.com/dialog/share",
img:"srcUrl"
},kaixin001:{name:"\u5f00\u5fc3\u7f51",
u:"http://www.kaixin001.com/rest/records.php"},tqf:{name:"\u817e\u8baf\u670b\u53cb",
u:"http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey"},tieba:{name:"\u767e\u5ea6\u8d34\u5427",
u:"http://tieba.baidu.com/f/commit/share/openShareApi",
img:"pic"},douban:{name:"\u8c46\u74e3\u7f51",
u:"http://www.douban.com/share/service"},tsohu:{name:"\u641c\u72d0\u5fae\u535a",
u:"http://t.sohu.com/third/post.jsp"},sqq:{name:"QQ\u597d\u53cb",
u:"http://connect.qq.com/widget/shareqq/index.html"},thx:{name:"\u548c\u8baf\u5fae\u535a",
u:"http://t.hexun.com/minilogin.aspx"},qq:{name:"QQ\u6536\u85cf",
u:""},more:{name:"\u66F4\u591A\..."}
};
var ld_share_site_my=["qzone","tsina","weixin","tqq","more","renren","kaixin001","tqf","douban","tieba","tsohu","sqq"];

function ld_share_click(item)
{
	var cmd = $(item).attr("data-cmd");
	var morepara = "";
	switch(cmd)
	{
		case "weixin":
			$.getScript(HU+"app/share/jquery.qrcode.min.js",function(){
				layer_view("分享到微信朋友圈",this,320,'','anc_delbody',"HTML:<table style='margin:16px 0;width:100%;text-align:left;'><tr><td align=center valign=middle><span id=ldshare_wenxin></span><br><br>打开微信，点击底部的发现，使用<br>扫一扫即可将网页分享至朋友圈。</td></tr></table>","",1,"",1,0,"setCenterDiv($('#anc_delbody'))");
				if(Browser.is_ie_lower||Browser.ie9)
				$("#ldshare_wenxin").qrcode({
					render: "table", 
					width: 200, 
					height:200, 
					text: location.href
				});
				else
				$("#ldshare_wenxin").qrcode({
					width: 200, 
					height:200, 
					text: location.href
				});
			});
			
			return false;
		case "more":
			ld_share_init();
			return false;
		case "tqq":
			morepara = "c=share&a=index&";
	}
	var s_title = ($(document).attr("title")||'').replace(/\ \-\ [\s\S]*/gi,"");
	if(s_title=="")s_title=DEF_title;
	var s_summary = $("meta[name=Description]").attr("content");
	var s_pic = $(".a_image").attr("src")||'';
	var s_flash = "";
	if(s_pic.substr(0,3) == "../")s_pic=DEF_URL+s_pic.substr(3);
	$(".lrc_source").each(function(){
		if(s_flash=="")
		if($(this).attr("href").indexOf(".swf")!=-1)s_flash=$(this).attr("href");
	});
	var ld_share_para = {
	url:location.href, /*获取URL，可加上来自分享到QQ标识，方便统计*/
	desc:'好帖子，分享分享', /*分享理由(风格应模拟用户对话),支持多分享语随机展现（使用|分隔）*/
	title:s_title, /*分享标题(可选)*/
	summary:s_summary, /*分享摘要(可选)*/
	pics:s_pic, /*分享图片(可选)*/
	flash:s_flash /*视频地址(可选)*/
	};
	var s = [],tmp;
	for(var i in ld_share_para){
	if(i=="pics")
	{
		tmp = ld_share_site[cmd].img||i;
	}
	else
	tmp = i;
	if(i!="img")
	s.push(tmp + '=' + encodeURIComponent(ld_share_para[i]||''));
	}
	var openur = ld_share_site[cmd].u + "?"+morepara+s.join('&');
	switch(cmd)
	{
		case "kaixin001":
			openur+="&style=11";
			break;
	}
	window.open(openur);
}
function ld_share_init(t)
{
		var s = "",n=0;
	for(var i=0;i<ld_share_site_my.length;i++)
	{
		if(t==0)
		if(++n>5)break;
		var index = ld_share_site_my[i];
		var val = ld_share_site[index];
		if(index == "more"&&t!=0)
		{}
		else
		s+="<a title=\"分享到"+val.name+"\" class=\"lds_"+index+"\" href=\"#\" data-cmd=\""+index+"\"></a>\n";
		};
	$(".ld_share").html(s);
	$(".ld_share a").each(function(){
		$(this).bind("click",function(){
			ld_share_click($(this));
			return false;
			});
	});
}

$(document).ready(function() 
{
	$import(HU+"app/share/share.css","css","");
	ld_share_init(0);
});