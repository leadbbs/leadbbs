//JSON DATA GET API FOR LEADBBS
//2014-03-20
var isMobile = (navigator.userAgent.match(/mobile/i));
isMobile = true;


var APIDATA = {
	"youku":{
		"proxy":true,
		"getkey": function(L){
					var m = L.replace(/([\s\S]*)http?s\:\/\/(v|player)\.youku\.com\/(v\_show|embed)\/(id\_)?([a-z0-9\=\%]{8,23})([\s\S]*)/i,function($0,$1,$2,$3,$4,$5){return $5;});
					if(m.length<8||L==m)
					m = L.replace(/([\s\S]*)http?s\:\/\/player\.youku\.com\/player.php\/sid\/([a-z0-9\=\%]{8,23})([\s\S]*)/i,function($0,$1,$2){return $2;});
					return(m);
				},
		"geturl": function(key){return("http://v.youku.com/player/getPlayList/VideoIDS/"+escape(key)+"/timezone/+08/version/5/source/out?password=&ran=2513&n=3");},
		"trueurl": function(key){
			if(isMobile)
			return("https://player.youku.com/embed/"+key+"?.mp4");
			else
			return("https://player.youku.com/embed/"+key+"?.mp4");
			//return("http://player.youku.com/player.php/sid/"+key);
			//return("http://player.youku.com/player.php/sid/"+key+"/v.swf");
			},
		"logo": function(d,m){return(d.data[0].logo);},
		"title": function(d,m){return(d.data[0].title);}
		},
	"56":{
		"proxy":true,
		"getkey":function(L){
					var m = L.replace(/([\s\S]*)http\:\/\/www\.56\.com\/[a-z0-9]{1,50}\/v?\_?([a-z0-9]{8,15})([\s\S]*)/i,function($0,$1,$2){return $2;});
					if(m.length<8||L==m)
					m = L.replace(/([\s\S]*)http\:\/\/player\.56\.com\/v\_([a-z0-9]{8,15})([\s\S]*)/i,function($0,$1,$2){return $2;});
					if(m.length<8||L==m)
					m = L.replace(/([\s\S]*)https?\:\/\/(www\.)?56\.com\/[a-z0-9]+\/(play_album\-aid\-[0-9]+_vid\-([a-z0-9_=\-]+)|v_([a-z0-9_=\-]+))([\s\S]*)/i,function($0,$1,$2,$3,$4){return $4;});
					return(m);
				},
		"geturl": function(key){
			var t = APIJSON.get56sign(key);
			return("http://oapi.56.com/video/getVideoInfo.json?vid="+escape(key)+"&appkey="+t[1]+"&sign="+t[0]+"&ts="+t[2]);
			},
		"trueurl": function(key){
			if(isMobile)
			return("http://www.56.com/iframe/"+escape(key));
			else
			return("http://player.56.com/v_" + escape(key) + ".swf");},
		"logo": function(d,m){return(d['0'].mimg);},
		"title": function(d,m){return(d['0'].title);}
	},
	"tudou":{
		"proxy":true,
		"getkey":function(L){
					var m = L.replace(/([\s\S]*)https?\:\/\/(www\.)?tudou\.com\/programs\/view\/html5embed.action\?type=([0-9]+)\&code\=([a-z0-9]{8,15})([\s\S]*)/i,function($0,$1,$2,$3,$4){
					return $4;});
					if(L==m||m.length<5)
					{
						m = L.replace(/([\s\S]*)https?\:\/\/(www\.)?tudou\.com\/[a-z0-9]+\/([a-z0-9]+?)\/([a-z0-9\&\=]{1,100})?\&[a-z]{1,5}\=([0-9]{9,15})([\s\S]*)/i,function($0,$1,$2,$3,$4,$5){
						if($5)
						return $5;
						else
						return $3;});
					}
					if(L==m||m.length<5)
					m = L.replace(/([\s\S]*)https?\:\/\/(www\.)?tudou\.com\/(programs\/view|listplay|v|l|albumplay\/([a-z0-9_=\-]+))\/([a-z0-9\_\=\-]+)([\s\S]*)/i,function($0,$1,$2,$3,$4,$5){return $5;});
					return(m);
				},
		"geturl": function(key){return("http://api.tudou.com/v3/gw?method=item.info.get&appKey=myKey&format=json&itemCodes="+escape(key));},
		"trueurl": function(key){			
			if(isMobile)
			return("http://www.tudou.com/programs/view/html5embed.action?type=0&code="+escape(key));
			else
			return("http://www.tudou.com/v/"+escape(key)+"/v.swf");},
		"logo": function(d,m){return(d.multiResult.results[0].bigPicUrl);},
		"title": function(d,m){return(d.multiResult.results[0].title);}
		},
	"xiami":{
		"proxy":false,
		"getkey":function(L){
					m = L.replace(/([\s\S]*)https?\:\/\/(www\.)?xiami\.com\/widget\/[0-9]+\_([0-9]+)\/singleplayer\.swf([\s\S]*)/i,"song|$3");
					if(L==m)
					m = L.replace(/([\s\S]*)https?\:\/\/(www\.)?xiami\.com\/widget\/[0-9]+\_([0-9\,]+)[0-9a-z\_]+\/(multiplayer|albumplayer)\.swf([\s\S]*)/i,function($0,$1,$2,$3,$4){
						if(($4+"").toLowerCase()=="multiplayer")
						return "songlist|"+$3;
						else
						return "album|"+$3;
					});
					if(L==m)
					m = L.replace(/([\s\S]*)https?\:\/\/(www\.)?xiami\.com\/widget\/([0-9]+)[0-9a-z\_]+\/wallplayer\.swf([\s\S]*)/i,"wall|$3");
					return(m);
				},
		"geturl": function(key){
				var t = m.split("|");
				if(t[1])
				switch(t[0])
				{
					case "song":
					case "songlist":
					case "album":
						return("http://goxiami.duapp.com/?id="+escape(t[1])+"&type="+t[0]);
						break;
					default:
						return("");
				}			
			},
		"trueurl": function(key){return("");},
		"logo": function(d,m){
				switch(m.split("|")[0])
				{
					case "song":
						return d.song_cover;
					case "songlist":
						for (var o in d) 
						{
							return d[o].song_cover;
						};
					case "album":
						return d.album_cover;
				}
			},
		"title": function(d,m){
				switch(m.split("|")[0])
				{
					case "song":
						return d.song_title+" - "+d.song_author;
					case "songlist":
						var v = "",n=0;
						for (var o in d) 
						if(o){if(v=="")v=d[o].song_title +" - "+d[o].song_author;n++;}
						return "(\u5171"+n+"\u9996) " + v + " ...";
					case "album":
						var n=0;
						for (var o in d.songs){if(o)n++;};
						return "(\u5171"+n+"\u9996) "+d.album_title+" - "+d.album_author;
				}
			}
		}
}

APIDATA.youtube={
		"proxy":false,
		"getkey":function(L){
					var m = L.replace(/([\s\S]*)https?\:\/\/(www|m)?(\.)?(youtube|youtu)\.(com|be)\/embed\/([a-z0-9\_]{9,15})([\s\S]*)/i,function($0,$1,$2,$3,$4,$5,$6){return $6;});

					if(L==m||m.length<5)
					{
						m = L.replace(/([\s\S]*)https?\:\/\/(www|m)?(\.)?(youtube|youtu)\.(com|be)\/(watch\?v\=|v\/|details\?v\=)?([a-z0-9\_]{11,11})([\s\S]*)/i,function($0,$1,$2,$3,$4,$5,$6,$7){return $7;});
						return(m);
					}
					return(m);
				},
		"geturl": function(key){return("http://gdata.youtube.com/feeds/api/videos/"+key+"?v=2&alt=jsonc");},
		"trueurl": function(key){
			if(isMobile)
			return("http://www.youtube.com/embed/"+escape(key));
			else
			return("http://www.youtube.com/v/"+key+"?version=3&f=videos&app=youtube_gdata&v.swf");},
		"logo": function(d,m){return(d.data.thumbnail.hqDefault);},
		"title": function(d,m){return(d.data.title);}
	}
APIDATA.leadbbs={
		"proxy":false,
		"getkey":function(L){
					var u = APIJSON.baseURI;
					var p=window.location.port;
					if(p!=""&&p!="80")u = u + ":" + p;
					u = u.replace(/(\.|\-)/gi,"\\$1")+"\\/";
					var m = L.replace(eval("/([\\s\\S]*)https?\\:\\/\\/(www|w)?(\\.)?("+u+"|leadbbs\\.com\\/|53520\\.com\\/|bzrzy\\.cn\\/)([a-z0-9\\/\\\\\\_]*)?a\\/topic\\-([0-9]+)\\-([0-9]+)\\-([0-9]+)\\-?([0-9]+)?\\.html([\\s\\S]*)/i"),"$1$2$3$4$5a/a.asp?b=$6&id=$7&aq=$8&q=$9");
					if(L==m)
					m = L.replace(eval("/([\\s\\S]*)https?\\:\\/\\/(www|w)?(\\.)?("+u+"|leadbbs\\.com\\/|53520\\.com\\/|bzrzy\\.cn\\/)([a-z0-9\\/\\\\\\_]*)?a\\/a.asp\\?b\\=([0-9]+)\\&id\\=([0-9]+)(\\&aq\\=)?([0-9]+)?(\\&q\\=)?([0-9]+)?([\\s\\S]*)/i"),"$1$2$3$4$5a/a.asp?b=$6&id=$7&aq=$9&q=$11");
					return(m);
				},
		"geturl": function(key){return("http://"+key);},
		"trueurl": function(key){return("http://"+key);},
		"logo": function(d,m){return(d.logo);},
		"title": function(d,m){return [d.title,d.description];},
		count:0
	}

var APIJSON = {
	proxyurl : HU+"a/proxy.asp",
	count : 0,
	baseURI : "",
	cur_mediaget : null,
	checkgetJson : function(obj){
				if($(obj).eq(0).attr("finish")!="1")$(obj).eq(0).attr("finish","1");
				APIJSON.get_mediainfo();},
	nextStep : function(){
				$(APIJSON.cur_mediaget).eq(0).attr("finish","1");
				APIJSON.get_mediainfo();},
	APISITE : [["youku.com","youku","\u4F18\u9177\u89C6\u9891","swf","html5"],
				["56.com","56","56\u89C6\u9891","swf","html5"],
				["tudou.com","tudou","\u571F\u8C46\u89C6\u9891","swf","html5"],
				["xiami.com","xiami","\u867E\u7C73\u97F3\u4E50\u7F51","swf","flash"],
				["youtube.com|youtu.be","youtube","YOUTUBE\u89C6\u9891","swf","html5"],
				["leadbbs.com|53520.com|bzrzy.cn|bbs.com","leadbbs","LEADBBS\u5B98\u65B9\u7AD9","htm",""]
				],
	getsite : function(L){
			var s = (chklink(L,true)+"").toLowerCase(); 
			for(var i=0;i<APIJSON.APISITE.length;i++)
			if(("|"+APIJSON.APISITE[i][0]+"|").indexOf("|"+s+"|")!=-1)
			return [APIJSON.APISITE[i]];
			return ["",""];
	},
	get_mediainfo : function()
	{
		//max callback number
		if(APIJSON.count > 19)return;
		var cur_mediaget = APIJSON.cur_mediaget = $(".lrc_source[finish!=1],.page_source[finish!=1]")[0];
		if(cur_mediaget)
		{
			var L = ($(cur_mediaget).attr("href")||"").replace(/\\/,"\/");
			var m = "";
			var site = APIJSON.getsite(L)[0];
			var SiteType = site[1];
			if(SiteType||""!="")m = APIDATA[SiteType].getkey(L);
			if(!(m.length>=1&&L!=m))
			{
				APIJSON.nextStep();
				return;
			}
			
			var jsonurl = APIDATA[SiteType].geturl(m);
			var true_href = APIDATA[SiteType].trueurl(m);
			if(true_href=="")true_href=L;

			$(cur_mediaget).attr("href",true_href);
			if($(cur_mediaget).find("img")[0]||jsonurl=="")
			{
				APIJSON.nextStep();
				return;
			}
			setTimeout(function(){APIJSON.checkgetJson($(cur_mediaget))}, 3000);
			if(site[4]=="html5"&&isMobile)$(cur_mediaget).attr("data-type","html5");
			$.getJSON((APIDATA[SiteType].proxy==true)?APIJSON.proxyurl+"?u=" + escape(jsonurl) + "&utf8=1&callback=?":jsonurl+((jsonurl.indexOf("?")==-1)?"?":"&")+"callback=?",function(d){

				var logo = "",T = "";
				try{
					logo = htmlencode(APIDATA[SiteType].logo(d,m));
					T = APIDATA[SiteType].title(d,m);
				}
				catch(e)
				{
					APIJSON.nextStep();
					return;
				};

				if(site[3]!="swf")
				{
					APIJSON.count++;
					if(APIDATA.leadbbs.count++<5)
					{
						$(cur_mediaget).eq(0).attr("finish","1");
						
						if(((T[0]+"")=="")==true)
						{APIJSON.nextStep();return;}
						
						var outs = (logo=="")?HU+"images/100.jpg":htmlencode(logo)
						outs = "<span class=json_data><img src="+outs+" class=jsonapi_logo>"
						$(cur_mediaget).append(outs+"<span class=jsonapi_title>"+htmlencode(T[0])+"</span><span class=jsonapi_description>"+htmlencode(T[1])+"</span></span>");
						$(cur_mediaget).show();
						APIJSON.get_mediainfo();
					}
					else
					{APIJSON.nextStep();return;}
				}
				else
				{
					APIJSON.count++;
					if(T!="")$(cur_mediaget).eq(0).attr("title",htmlencode(T)).find("span").html(T);
					if(site[4]=="html5"&&isMobile)$(cur_mediaget).attr("data-type","html5");
					
					if(logo!=""&&logo)
					{
						$("<img/>").attr("src",logo).bind("error",function(){
							APIJSON.nextStep();return;
							}).load(function(){
					         var w = this.width;
					         var h = this.height;
								h=h<30?30:h;
								w=w>640?640:w;
								h=h>480?480:h;
								w=w<120?120:w;
								if(isMobile){$(cur_mediaget).parent().css("max-width","96%").find("img").css("max-width","96%");}
								$(cur_mediaget).css("background","url(\""+logo+"\")");
								$(cur_mediaget).parent().css("width",w).css("height",h).find("img").css("width",w).css("height",h);
								var txt_obj = $(cur_mediaget).eq(0).attr("finish","1").css("position","relative").find("span");
								var txt = $(txt_obj).html();
								var insertTxt = "<div style=\"filter:alpha(opacity=50);opacity:0.5;position:absolute;background:#000;bottom:0px;left:0px;display:block;width:100%;Height:24px;\"></div>"
								insertTxt += "<div style=\"text-shadow: 0 0 0 #eee;font-size:12px;position:absolute;bottom:0px;left:0px;display:block;color:white;width:100%;height:24px;line-height:24px;\">"+txt+"</div>";
								$(txt_obj).remove();
								$(cur_mediaget).eq(0).append(insertTxt);
								APIJSON.get_mediainfo();
								return;
						});
					}
				}
			});
		}
	},
	get56sign : function(aid)
	{
		var m = md5("vid=" + aid);
		var ts = Math.floor((new Date()).getTime()/1000);
		var appkey = "3000004018"; //56 appkey
		var secret = "c76ee13776324828"; //56 secret
		ts = 1395338278;
		m = md5(m + "#" + appkey + "#" + secret + "#" + ts);
		return [m,appkey,ts];
	}
};

function init_pagesource()
{
	if(!$(".anc_table_div")[0] && !$(".postmessage")[0])return;
	
	var u = window.location.href;
	if(u.replace(/([0-9\.]*)/gi,"")!="")
	u = chklink(window.location.href,true);
	APIJSON.baseURI = u;
	APIJSON.APISITE[5][0] = u + "|" + APIJSON.APISITE[5][0];
	$("a[data-autolink]").each(function(){
		var L = $(this).attr("href").replace(/\\/,"\/");	
		var site = APIJSON.getsite(L)[0];
		var SiteType = site[1];
		var sitename = site[2];
		var m="";
		if(SiteType||""!="")m = APIDATA[SiteType].getkey(L);

		if(m.length>=1&&L!=m)
		{
			var w = 640,h = 480;
			var true_href = APIDATA[SiteType].trueurl(m);
			if(true_href=="")true_href=L;
			var from = L;
			switch(SiteType)
			{
				case "xiami":
					var t = m.split("|");
					if(t[0]=="song"){w=257;h=33;}
					if(t[0]=="songlist"||t[0]=="album"){w=235;h=346;}
					if(t[0]=="wall"){w=451;h=179;}
					from = "\u6765\u81EA\u867E\u7C73\u97F3\u4E50\u7F51";
					break;
				default:
					from = "\u6765\u81EA" + sitename;
					break;
			}
			switch(site[3])
			{
				case "swf":	
					$(this).after("<div class=clear></div>" + bbsmedia(true_href,"","swf",w,h));
					if($(this).attr("href")==$(this).text()||htmlencode($(this).attr("href"))==$(this).text())$(this).html(from);
					$(this).attr("href","javascript:;").css("font-size","9pt").click(function(){return false;});;
					break;
				case "htm":
					$(this).after("<div class=clear></div><a class=\"page_source\" target=\"_blank\" style=\"display:none\" href=\"" + htmlencode(true_href) +"\"></a>");
					break;
			}			
		}
	});
	$.getScript(HU+"inc/js/md5.js",function(){APIJSON.get_mediainfo();});
}
$(document).ready(function() {
	init_pagesource();
});