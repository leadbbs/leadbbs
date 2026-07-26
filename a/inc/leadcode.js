/*
	LeadBBS.COM
	2007-08-31
*/
var vnum = 0; //1  forbid play,-2 allow 3 video to play at same time. 0: allow one
var GBL_domain=GBL_domain||"",DEF_DownKey="";

var autoplay = 0; //0.manual play 1.auto play
var playcount = 2; //play loop count:0-100,0=always replay


var nowobj=vnum+1;
function $id(s) {return document.getElementById(s);}
function mpplay(n)
{
	if(confirm("\u6b64\u64cd\u4f5c\u5c06\u8c03\u7528\u672a\u77e5\u6587\u4ef6\u64ad\u653e\uff0c\u786e\u5b9a\u7ee7\u7eed\u5417\uff1f"))
	{
	if(Browser.ie)$id('MediaPlayer' + nowobj).controls.stop();
	$id("mplay" + nowobj).style.display="none";
	$id("mplayerurl" + nowobj).style.display="block";
	
	nowobj = n;
	$id("mplayerurl" + n).style.display="none";
	$id("mplay" + n).style.display="block";
	if(Browser.ie)$id('MediaPlayer' + n).controls.play();
	}
}

function leadcode(d)
{
	if ($id(d))
	{
		var str=convertcode($id(d).innerHTML);
		$id(d).innerHTML = convertcode($id(d).innerHTML);
	}
}


function leadcodebycom()
{
}

function leadcode_uw(id)
{
	if ($id(id))
	{
		$id(id).innerHTML = convertcode_uw($id(id).innerHTML);
	}
}

function url_filter(str)
{
	var tmp = str;
	tmp = tmp.replace(/(javascript|jscript|js|about|file|vbscript|vbs)(:)/gim,"$1%3a");
	tmp = tmp.replace(/(value)/gim,"%76alue");
	tmp = tmp.replace(/(document)(.)(cookie)/gim,"$1%2e$3");
	tmp = tmp.replace(/(')/g,"%27");
	tmp = tmp.replace(/(")/g,"%22");
	//tmp = tmp.replace(/(\@)/g,"%40");
	return(tmp);
}

function adjustW(obj)
{
	obj.onload = null;
	if(obj.width>520)obj.width=520;
}

function convertupload(id,ty,fname)
{
	var u = HU + "a/file.asp?lid=" + id + "&s=" + DEF_DownKey;
	u = u.replace(/\|/gi,"%7c");
	var fstr=(fname.indexOf(".")>=0)?fstr=" download=\""+fname.replace(/\"/g,"")+"\"":"";
	var fnm = fname.replace(/\|/gi," ");
	if(fnm!="")fnm="|" + fnm;
	switch(parseInt(ty))
	{
	case 0:
		return("[IMG]" + u + "[/IMG]");
	case 1:
		return("<div class=ubb_box>[FLASH]" + u + "&r=1" + fnm + "[/FLASH]<br><br><a href=" + u + "&down=1 target=_blank" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>\u70b9\u51fb\u4e0b\u8f7dFlash</a></div>");
	case 4:
		return("<div class=ubb_box>[MP=320,68]" + u + "&r=1" + fnm + "[/MP]<br><br><a href=" + u + "&down=1 target=_blank" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>\u70b9\u51fb\u4e0b\u8f7d\u97f3\u9891</a></div>");
	case 5:
		return("<div class=ubb_box>[MP=320,309]" + u + "&r=1" + fnm + "[/MP]<br><br><a href=" + u + "&down=1 target=_blank" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>\u70b9\u51fb\u4e0b\u8f7d\u89c6\u9891</a></div>");
	default:
		return("<a href=" + u + "&down=1 title=\u70b9\u51fb\u4e0b\u8f7d\u9644\u4ef6 target=_blank" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>" + fname + "</a>");
	}
}

function getuncode(obj)
{
	return(unhtmlencode($("#"+obj).html()));
}

function runCode(obj) {
	if(confirm('\u6B64\u64CD\u4F5C\u5C06\u65B0\u5F00\u7A97\u53E3\u67E5\u770B\u6216\u662F\u8FD0\u884C\u4EE3\u7801\uFF0C\u786E\u5B9A\u5C06\u7EE7\u7EED\u6B64\u64CD\u4F5C\u3002'))
	{
	var txt = getuncode(obj);
	//.parentNode.parentNode.innerText;
	//txt = txt.substring(9,txt.length);
	var winname = window.open('', "_blank", '');
	winname.document.open('text/html', 'replace');
	winname.opener = null;
	winname.document.write(txt);
	winname.document.close();
	}
}

var covn = 0;

function unhtmlencode(s)
{
return(s.replace(/\<br\/\>/g, '\n').replace(/\<br \/\>/g, '\n').replace(/\<br\>/g, '\n').replace(/\&lt;/g, '\<').replace(/\&gt;/g, '\>').replace(/\&quot;/g, '\x22').replace(/\&#39;/g, '\x27').replace(/\&amp;/g, '\&').replace(/\&nbsp;/g, '\ '));
}
function htmlencode(str)
{
	return(str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\x22/g, '&quot;').replace(/\x27/g, '&#39;'));
}

function convertcode(str)
{
	str = str.replace(/\n\r/g, "");
	str = str.replace(/\r\n/g, "");
	str = str.replace(/\n/g, "");
	str = str.replace(/\ \[\/(td)\]/gim,"&nbsp;[/$1]");
	str = str.replace(/\[code\](.*?)\[\/code\]/gim,function($0,$1){var s = $1;covn++;$("body").prepend("<div style='display:none;' id=code_hide"+covn+">"+s+"</div>\n");s=s.replace(/\[/g,'&#91;');s=s.replace(/\]/g,'&#93;').replace(/\<br\>/gi,'&nbsp;</span></li>\r\n<li><span>').replace(/\<br \/\>/gi,'</span></li><li><span>');return ("<div class=ubb_code><span style='cursor:pointer;' onclick=runCode('code_hide"+covn+"')>\u8FD0\u884C\u4EE3\u7801</span> <span class=layerico><a href=javascript:; onclick=copyClipboard('Text',getuncode('code_hide"+covn+"'),'\u590d\u5236\u6210\u529f','" + HU + "',this)>\u590d\u5236\u4ee3\u7801</a></span><ol id=ubbcode><li><span>"+s+"</span></li></ol></div>")});
	str = str.replace(/\[tshow=([0-9]{1,2}),([0-9]{1,2}),([0-9]{1,2}),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\](.*?)\[\/tshow\]/gim,function($0,$1,$2,$3,$4,$5){
	//var s = $1;covn++;$("body").prepend("<div style='display:none;' id=code_hide"+covn+">"+s+"</div>\n");s=s.replace(/\[/g,'&#91;');s=s.replace(/\]/g,'&#93;').replace(/\<br\>/gi,'&nbsp;</span></li>\r\n<li><span>').replace(/\<br \/\>/gi,'</span></li><li><span>');return ("<div class=ubb_code><span style='cursor:pointer;' onclick=runCode('code_hide"+covn+"')>\u8FD0\u884C\u4EE3\u7801</span> <span class=layerico><a href=javascript:; onclick=copyClipboard('Text',getuncode('code_hide"+covn+"'),'\u590d\u5236\u6210\u529f','" + HU + "',this)>\u590d\u5236\u4ee3\u7801</a></span><ol id=ubbcode><li><span>"+s+"</span></li></ol></div>")
	var s = $5;
	if(!$("#tshowstyle_"+$1+"")[0])$("head").append("<style id=tshowstyle_"+$1+">.tshow_"+$1+"{display:block;float:left;width:"+$2+"px;height:"+$2+"px;background:url("+HU+"images/font/font_"+$1+".png);text-align:center;line-height:"+$2+"px;font-size:"+$3+"px;color:"+$4+";}</style>");
	if(s.length>1)
	return("<span class=tshow_"+$1+">"+(s.split("").join("</span><span class=tshow_"+$1+">")).replace(/\[/g,'&#91;').replace(/\]/g,'&#93;')+"</span>");
	else
	return("<span class=tshow_"+$1+">"+s.replace(/\[/g,'&#91;').replace(/\]/g,'&#93;')+"</span>");
	});

	str = str.replace(/\[upload=([0-9]{1,14}),([0-9]{1,1})\](.+?)\[\/upload\]/gim,function($0,$1,$2,$3){return convertupload($1,$2,$3);});

	str = str.replace(/\[em([0-9]{1,4})\]/gi,"<img src=\"" + HU + "images/UBBicon/em$1.GIF\" align=absmiddle>");

	str = str.replace(/\[(\/?(u|b|i|sup|sub|strike|ul|ol|tr|td|pre|p|li|blockquote))\]/gim,"<$1>");
	str = str.replace(/\[td=([0-9]{1,2}),([0-9^\,]{1,2})[\,]?([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))?\]/gim,function($0,$1,$2,$3){var s=($3=="")?"":" bgColor=\""+$3+"\"";return("<td colspan=" + $1 + " rowspan=" + $2 + s + ">")});
	str = str.replace(/\[hr\]/gim,"<hr size=1 class=splitline>");
	str = str.replace(/\[(\/?)\*\]/gim,"<$1li>");
	str = str.replace(/\[(\/?)PP\]/gim,"<$1p>");

	str = str.replace(/\[quote\](.*?)\[\/quote\]/gim,"<table border=0 cellspacing=0 cellpadding=0><tr><td><div class=ubb_quote><div class=ubb_quotein><table border=0 cellspacing=0 cellpadding=0><tr><td>$1</td></tr></table></div></div></td></tr></table>");

	str = str.replace(/\[face=(.+?)\]/gim,function($0,$1){return("<span face=\"" + $1 + "\">");});
	str = str.replace(/\[FIELDSET=(.+?)\](.*?)\[\/FIELDSET\]/gim,"<FIELDSET><LEGEND>$1</LEGEND>$2</FIELDSET>");

	str = str.replace(/\[size=([0-9]{1,1})\]/gim,"<span size=\"$1\">");
	str = str.replace(/\[size=([a-z0-9\-\%]{1,4})\]/gim,"<span style=\"font-size:$1;line-height:2em;\">");
	str = str.replace(/\[color=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<span style=\"color:$1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<span style=\"BACKGROUND-COLOR: $1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<span style=\"BACKGROUND-COLOR: $1\" color=\"$2\">");
	str = str.replace(/\[\/(color|size|face|font|bgcolor)\]/gim,"</span>");
	str = str.replace(/\[LINE\-HEIGHT=(normal|[\.\%ptx0-9]{1,5})\]/gim,"<span style=\"line-height:$1\">");
	str = str.replace(/\[\/(line\-height)\]/gim,"</span>");
	str = str.replace(/\[(glow|SHADOW)=([0-9]{1,2})[0-9]?,([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3})\](.*?)\[\/(glow|SHADOW)\]/gim,"<div style=\"vertical-align:middle;display: inline-block;*display: inline;zoom:1;filter:glow(color=$3, strength=$4);text-shadow: $2px $2px $4px $3;\" style=\"\">$5</div>");
	str = str.replace(/\[fly\](.*?)\[\/fly\]/gi,"<MARQUEE>$1</MARQUEE>");

	str = str.replace(/\[email[\=]?(.*?)\](.*?)\[\/email\]/gim,function($0,$1,$2){if($1=="")$1=$2;if($2=="")$2=$1;return("<a href=\"mailto:" + url_filter($1).replace(/\@/,"&#64;") + "\">" + $2.replace(/\@/,"&#64;") + "</a>")});

	str = str.replace(/\[align=(left|center|right|justify)\]/gim,"<span style=\"clear:both;display:block;text-align:$1\">");
	str = str.replace(/\[\/align\]/gim,"</span>");
	str = str.replace(/\[imga?=?([0-9]{1,2})?,?(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)?,?([0-9\%]{1,5})?,?([0-9\%]{1,5})?\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga?\]/gi,function($0,$1,$2,$3,$4,$5,$6){
		var b = $1?" border=\""+$1+"\"":"";
		var w = $4?" width=\""+$4+"\"":"";
		var h = $3?" height=\""+$3+"\"":"";
		var a = $2?" align=\""+$2+"\"":"";
		return("<img src=\"" + HU + "images/lazy.png\" data-url=\"" + url_filter($5+$6) + "\"" + w + h + a + b + " class=\"a_image\" rel=\"lightbox\" onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});
	
	str = str.replace(/\[(img|imga)=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop),([0-9\%]{1,5}),([0-9\%]{1,5})\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/(img|imga)\]/gi,function($0,$1,$2,$3,$4,$5,$6,$7){return("<img rel=\"lightbox\" height=" + $4 + " src=\"" + HU + "images/lazy.png\" data-url=\"" + url_filter($6+$7) + "\" class=\"a_image\" width=" + $5 + " align=\"" + $3 + "\" border=\"" + $2 + "\" />")});

	str = str.replace(/\[MP=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/MP\]/gi,function($0,$1,$2,$3){
		//if(!Browser.is_ie_lower)
		return(bbsmedia($3,"","other",$1,$2));
		//else
		//{
		//	var u=url_filter($3),w=$1,h=$2;if (chklink(u)&&vnum<1){vnum++;return("<span id=mplay" + vnum + "><object align=middle classid=CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6 class=OBJECT id=MediaPlayer" + vnum + " width=\"" + w + "\" height=\"" + h + "\"><param name=ShowStatusBar value=-1><param name=url value=\"" + u + "\" /><embed src=\"" + u + "\" width=\"" + w + "\" height=\"" + h + "\" autostart=" + autoplay + " PlayCount=\"" + playcount + "\" type=video/x-ms-wmv></embed><param name=AUTOSTART value=" + autoplay + " /><param name=\"PlayCount\" value=\"" + playcount + "\" /></object></span><span id=mplayerurl" + vnum + " onclick=\"mpplay(" + vnum + ");\" style=\"display:none;cursor:hand\"><IMG SRC=" + HU + "images/FileType/mp3.gif border=0 align=middle height=16 width=16>" + u + "</span>");} else {vnum++;return("<span id=mplay" + vnum + " style=\"display:none;\"><object align=middle classid=CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6 class=OBJECT id=MediaPlayer" + vnum + " width=\"" + w + "\" height=\"" + h + "\"><param name=ShowStatusBar value=-1 /><param name=url value=\"" + u + "\" /><embed src=\"" + u + "\" width=\"" + w + "\" height=\"" + h + "\" autostart=false type=video/x-ms-wmv></embed><param name=AUTOSTART value=0 /></object></span><span id=mplayerurl" + vnum + " onclick=\"mpplay(" + vnum + ");\" style=\"cursor:hand\"><IMG SRC=" + HU + "images/FileType/mp3.gif border=0 align=middle height=16 width=16>\u5a92\u4f53\u6587\u4ef6</span>");} 
		//}
	} );
	
	str = str.replace(/\[RM=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/RM\]/gi,function($0,$1,$2,$3){
		//if(!Browser.is_ie_lower)
		//return(bbsmedia($3,"","other"));
		//else
		//	{
		//		var u=url_filter($3),w=$1,h=$2;if (chklink(u)&&vnum<1){vnum++;return("<OBJECT classid=clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA class=OBJECT id=RAOCX width=\"" + w + "\" height=\"" + h + "\"><param name=SRC value=\"" + u + "\"><param name=CONSOLE value=\"2423" + u + "\"><param name=CONTROLS value=imagewindow><param name=AUTOSTART value=" + autoplay + "></OBJECT><br><OBJECT classid=CLSID:CFCDAA03-8BE4-11CF-B84B-0020AFBBCCFA height=32 id=video2 width=\"" + w + "\"><param name=SRC value=\"" + u + "\"><param name=AUTOSTART value=" + autoplay + "><param name=\"numloop\" value=\"" + playcount + "\" /><param name=CONTROLS value=controlpanel><param name=CONSOLE value=\"2423" + u + "\"></OBJECT>");} else {return("<IMG SRC=" + HU + "images/tc/2.gif border=0 align=middle height=16 width=16>" + getlink(u,"RM\u6587\u4ef6",0));} 
		return(bbsmedia($3,"","rm",$1,$2));
		//	}
		} );
	str = str.replace(/\[FLASH=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLASH\]/gi,function($0,$1,$2,$3){
	return(bbsmedia($3,"","swf",$1,$2));});
	str = str.replace(/\[FLASH\](.+?)\[\/FLASH\]/gi,function($0,$1){
	return(bbsmedia($1,"","swf",640,480));});
	
	
	str = str.replace(/\[FLV=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLV\]/gi,function($0,$1,$2,$3){
		
		return(bbsmedia($3,"","flv",$1,$2));
		} );

	str = str.replace(/\[url=(.+?)\](.*?)\[\/url\]/gi,function($0,$1,$2){if($2=="")$2=$1;return(getlink(url_filter($1),$2,0,true))});
	str = str.replace(/\[url\](.+?)\[\/url\]/gi,function($0,$1){return(getlink(url_filter($1),$1,1,true))});
	
	str = str.replace(/\[nulltable\](.+?)\[\/nulltable\]/gim,"<table border=0 cellspacing=0 cellpadding=0>$1</table>");
	str = str.replace(/\[nulltable=(.+?)\](.+?)\[\/nulltable\]/gim,function($0,$1,$2){return("<table border=0 width=100% cellspacing=0 cellpadding=0 background=\"" + url_filter($1) + "\">" + $2 + "</table>")});
	str = str.replace(/\[nulltr\](.+?)\[\/nulltr\]/gim,"<tr>$1</tr>");
	str = str.replace(/\[nulltd\](.+?)\[\/nulltd\]/gim,"<td>$1</td>");
	str = str.replace(/\[table\](.+?)\[\/table\]/gim,"<table class=anctb>$1</table>");
	str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)|transparent),([0-9]{1,3}),([0-9]{1,3}),([0-9\p\x\%\.\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)|transparent),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " style=\"background-color:" + $6 + ";background-image:" + url_filter($8) + "; border-color: " + $1 + ";\" border=" + $7 + ">" + $9+ "</table>")});
	str = str.replace(/\[sound\](.+?)\[\/sound\]/gim,function($0,$1){var u=url_filter($1);return("<a href=\"" + u + "\" target=_blank><IMG SRC=" + HU + "images/FileType/mid.gif border=0 alt=\"\u80cc\u666f\u97f3\u4e50\" height=16 width=16></a><bgsound src=\"" + u + "\" loop=-1>")});

	//str = str.replace(/\[FLV=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLV\]/gi,function($0,$1,$2,$3){var u=url_filter($3),w=$1,h=$2;if (vnum<3){vnum++;return("<embed src=\"" + HU + "images/pub/Flvplayer.swf?\" flashvars=\"vcastr_file=" + u + "\" quality=\"high\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" type=\"application/x-shockwave-flash\" allowFullScreen=\"true\" width=\"" + w + "\" height=\"" + h + "\"></embed>");} else {return("<IMG SRC=" + HU + "images/FileType/swf.gif border=0 align=middle height=16 width=16>" + getlink(u,"Flv\u6587\u4ef6",0));} } );
	//lrc start
	str = str.replace(/\[lrc=(\/|..\/|http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/)(.+?)\](.+?)\[\/lrc\]/gim,function($0,$1,$2,$3){
		
		return(bbsmedia($1+$2,$3,"lrc"));
		});
	//lrc end
	
	str = str.replace(/\[collapse(=[^\]]{1,50})?\]\s*(?:<br\s*\/?>)*\s*(.+?)\s*(?:<br\s*\/?>)*\s*\[\/collapse\]/gi,function($0,$1,$2){
		if ($1)$1='<b class="grayfont">'+$1.substr(1)+' ...</b>'
		else $1 = '<b class="grayfont">点击显示隐藏的内容 ...</b>'
		return "<div style='border-top:1px solid #fff;border-bottom:1px solid #fff'><button style='font-size:12px;line-height:normal;padding:2px 5px 0px 5px;margin-right:5px;' onclick='this.parentNode.style.display=\"none\";this.parentNode.nextSibling.style.display=\"block\";' type='button'><b>+</b></button>"+$1+"</div><div style='border-top:1px solid #fff;border-bottom:1px solid #fff;display:none'>"+$2+"</div>"
		});
	str = str.replace(/\[@(.{2,20}?)\]/gi,function($0,$1){ var u=$1,ns="name="+escape(u);
	if(u.indexOf(u,"#")!=-1)
	if(u.substr(0,3).toLowerCase!="qq#" && u.substr(0,3).toLowerCase!="ld#")
	{
		var s = u.split("#")
		u = s[0];
		ns="id="+escape(s[1])
	}
	return" <a href='"+HU+"user/lookuserinfo.asp?"+ns+"' class='username'>&#64;"+u+"</a> " } );//[@]
	//str = str.replace(/\@([a-z0-9\_]{2,20})/gi,function($0,$1){ return" <a href='"+HU+"user/lookuserinfo.asp?name="+escape($1)+"' class='username'>@"+$1+"</a> " } );//[@]
	//str = str.replace(/\@([^\ \　\.\"\'\[\]\(\)\<\>\&\\]{2,20})/gi,function($0,$1){ return" <a href='"+HU+"user/lookuserinfo.asp?name="+escape($1)+"' class='username'>@"+$1+"</a>" } );//[@]

	str = str.replace(/( |\n|\r|\t|\v|\<br\>|\uff1a|\:|\u3000|\>\])(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2,$3){var u=$2;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return($1+getlink(url_filter(u+$3),$2+$3,0,true));});
	str = str.replace(/^(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2){var u=$1;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return(getlink(url_filter(u+$2),$1+$2,0,true));});
	str = lead_multtb(str);
	return str;
}

function bbsmedia(u,con,t,w,h)
{
		var ur=u,st,urn,mtitle="",mpic="",splitur,auto="",width="",height="";
		splitur = ur.split("|");
		if(splitur.length>1)
		{
			ur = splitur[0];
			mtitle = splitur[1];
			if(splitur.length>2)
			{
				mpic=url_filter(splitur[2]);
				//if(mpic!="")mpic=' style="background:url(' + mpic + ') no-repeat;"';
				if(mpic!="")mpic='<img src="' + mpic + '" />';
			}
			if(splitur.length>3)
			{
				auto=splitur[3];
				auto=(auto=="1"||auto=="auto"||auto=="yes")?auto:"";
			}
		}
		if(!isNaN(w)&&!isNaN(h))
		{
			width = parseInt(w);
			height = parseInt(h);
			if(width<50)width="";
			if(height<20)height="";
			if(width>2000)width="";
			if(height>2000)width="";
			if(width==""||height==""){
				width="480px";height="270px";
				}
			else
			{width=width+"px";
			height=height+"px";}
		}
		else
		{width="";height="";}
		ur=ur.replace(/(^\s*)|(\s*$)/g,"");
		ur = url_filter(ur);

		if(mtitle=="")
		urn=ur.length>23?ur.substring(0,10)+"..."+ur.substring(ur.length-10,ur.length):ur;
		else
		urn=mtitle.replace(/\</gi,"&lt;");
		st='<div class="lrc_item">';
		var playstr=(t=="swf"||t=="rm")?"if(chklink(this.href)){lrc_play(this,\'"+t+"\',\'"+auto+"\',\'"+width+"\',\'"+height+"\');}else{if(confirm('\u6B64\u64CD\u4F5C\u5C06\u64AD\u653E\u672A\u8BA4\u8BC1\u5916\u7AD9\u64AD\u4F53\u6587\u4EF6\uFF0C\u6B64\u94FE\u63A5\u4E0D\u4E00\u5B9A\u5B89\u5168\uFF0C\u786E\u5B9A\u7EE7\u7EED\u5417\uFF1F"+ur+"'))lrc_play(this,\'"+t+"\',\'"+auto+"\',\'"+width+"\',\'"+height+"\');}":"lrc_play(this,\'"+t+"\',\'"+auto+"\',\'"+width+"\',\'"+height+"\');";
		st+='<a href="'+ur+'" class="lrc_source" onclick="'+playstr+'return false;">' + mpic + '<i class=\"video_play\"></i><span>'+urn+'</span></a>';
		if(t=="lrc")
		{
			st+='<div class="lrc_content">';
			st+=Browser.is_ie_lower?con:con.replace(/<br>/gi,"\n\r").replace(/<br \/>/gi,"\n\r");
			st+='</div>';
		}
		st+='</div>';
		return(st);
}

function convertcode_uw(str)
{
	str = str.replace(/\n/g, "");

	str = str.replace(/\[(\/?(u|b|i|sup|sub|strike|ul|ol|pre|p|li))\]/gim,"<$1>");
	str = str.replace(/\[(\/?)\*\]/gim,"<$1LI>");
	str = str.replace(/\[(\/?)PP\]/gim,"<$1P>");

	str = str.replace(/\[face=(.+?)\]/gim,function($0,$1){return("<font face=\"" + $1 + "\">");});

	str = str.replace(/\[size=([#0-9a-z]{1,20})\]/gim,"<font size=\"$1\">");
	str = str.replace(/\[color=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font color=\"$1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font style=\"BACKGROUND-COLOR: $1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font style=\"BACKGROUND-COLOR: $1\" color=\"$2\">");
	str = str.replace(/\[\/(color|size|face|font|bgcolor)\]/gim,"</font>");
	str = str.replace(/\[(glow|SHADOW)=([0-9]{1,2})[0-9]?,([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3})\](.*?)\[\/(glow|SHADOW)\]/gim,"<div style=\"vertical-align:middle;display: inline-block;*display: inline;zoom:1;filter:glow(color=$3, strength=$4);text-shadow: $2px $2px $4px $3;\" style=\"\">$5</div>");
	str = str.replace(/\[email=(.+?)\](.+?)\[\/email\]/gi,function($0,$1,$2){return("<a href=\"mailto:" + url_filter($1) + "\">" + $2 + "</a>")});
	str = str.replace(/\[email\](.+?)\[\/email\]/gi,function($0,$1,$2){return("<a href=\"mailto:" + url_filter($1) + "\">" + $1 + "</a>")});

	str = str.replace(/\[align=(left|center|right|justify)\]/gim,"<span style=\"text-align:$1\">");
	str = str.replace(/\[\/align\]/gim,"</span>");
	str = str.replace(/\[imga?=?([0-9]{1,2})?,?(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)?,?([0-9\%]{1,5})?,?([0-9\%]{1,5})?\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga?\]/gi,function($0,$1,$2,$3,$4,$5,$6){
		var b = $1?" border=\""+$1+"\"":"";
		var w = $4?" width=\""+$4+"\"":"";
		var h = $3?" height=\""+$3+"\"":"";
		var a = $2?" align=\""+$2+"\"":"";
		return("<img" + h + " src=\"" + url_filter($5+$6) + "\"" + w + a + b + " onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});

	str = str.replace(/\[url=(.+?)\](.+?)\[\/url\]/gi,function($0,$1,$2){return(getlink(url_filter($1),$2,0))});
	str = str.replace(/\[url\](.+?)\[\/url\]/gi,function($0,$1){return(getlink(url_filter($1),$1,1))});

	str = str.replace(/( |\n|\r|\t|\v|\<br\>|\uff1a|\:|\u3000)(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2,$3){var u=$2;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return($1+getlink(url_filter(u+$3),$2+$3,0));});
	str = str.replace(/^(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2){var u=$1;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return(getlink(url_filter(u+$2),$1+$2,0));});

	return str;
}

//check safe link.
function chklink(ul,getu)
{
	if(ul.substr(0,3) == '../'||ul.substr(0,1) == '/'){return 1;}
	var nn,ur,t,ur2;
	ur = ul;
	ur = ur.replace(/\|/gi,"").replace(/\\/gi,"\/");
	var t = ur.match(/(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/)([a-z0-9\.\-]*)/);
	if (t && t[2])
	ur = t[2];
	nn = ur.split(".");
	if(nn.length>2)
	ur=(nn[nn.length-2]+"."+nn[nn.length-1]);
	if(getu==true){return(ur)};
	if(nn.length>3)
	ur2=(nn[nn.length-3]+"."+ur);
	var allowlist=GBL_domain;
	if(GBL_domain=="|all|")return(1);
	if(allowlist.indexOf("|"+ur+"|")>=0||(allowlist.indexOf("|"+ur2+"|")>=0 && ur2!=""))
	{return(1);}
	else
	{return(0);}
}

//convert [url]
function getlink(url,nm,f,autoid)
{
	var ed = ">",t = '',t2 = '',u=url.replace(/(^\s*)/g,"");
	if (f == 1){t2 = "<img src=" + HU + "images/tc/5.gif border=0 align=absmiddle>";}
	if (chklink(u) == 0)
	{
		t = "<div class=altlink><span class=grayfont>" + (u.length<101?u:u.substring(0,70)+"......"+u.substring(u.length-24,u.length)) + "</span><br>\u8bbf\u95ee\u7f51\u5740\u8d85\u51fa\u672c\u7ad9\u8303\u56f4\uff0c\u4e0d\u80fd\u786e\u5b9a\u662f\u5426\u5b89\u5168 <br><a href=\"" + u + "\" onclick='$id(\"a_alt_link\").style.display=\"none\";' target='_blank'>\u7ee7\u7eed\u8bbf\u95ee</a> <a href='#ntg' onclick='$id(\"a_alt_link\").style.display=\"none\";'>\u53d6\u6d88\u8bbf\u95ee</a></div>";
		
		ed = " class=layer_alertclick onclick=\"layer_view('" + $replace($replace(t,String.fromCharCode(39),'\'+String.fromCharCode(39)+\''),'"','\'+String.fromCharCode(34)+\'') + "','','','','a_alt_link','','',0,'',0,-1314,'',event);return false;\"" + ed;
	};
	
	var aid = (autoid==true)?" data-autolink=\"ld_autolink\"":"";
	return (t2 + "<a href=\"" + u + "\""+aid+" target='_blank' " + ed + nm + "</a>");
}

function lead_multtb(s)
{
	var str = s;
	var oldstr = "",tmp;
	tmp = str.toLowerCase();
	while(oldstr != str)
	{	oldstr = str;
		str = str.replace(/\[table\](.+?)\[\/table\]/gim,"<table class=anctb>$1</table>");
		//str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),([0-9]{1,3}),([0-9\%\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table borderColor=" + $1 + " cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " bgColor=" + $6 + " background=\"" + url_filter($8) + "\" border=" + $7 + ">" + $9+ "</table>")});
		str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)|transparent),([0-9]{1,3}),([0-9]{1,3}),([0-9\p\x\%\.\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)|transparent),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " style=\"background-color:" + $6 + ";background-image:" + url_filter($8) + "; border-color: " + $1 + ";\" border=" + $7 + ">" + $9+ "</table>")});
		tmp = str.toLowerCase();
	}
	return(str);
}

function pause(numberMillis) {
	var now = new Date();
	var exitTime = now.getTime() + numberMillis;
	while (true) {
		now = new Date();
		if (now.getTime() > exitTime)
			return;
	}
}

var keyprs = 0;
function getLKeyup(e){
	if(keyprs==0)return false;
	var ev=Browser.ie?event:e;
	if(ev.ctrlKey||ev.altKey||ev.shiftKey)return;
	kc=ev.keyCode;
	LD.stope(ev);
	switch(kc)
	{
		case 27:
			hideLightbox();break;
		case 37:
			var t=light_next(curlt,"prev");
			if(t)showLightbox(t);break;
		case 39:
			var t=light_next(curlt);
			if(t)showLightbox(t);break;
	}
	keyprs = 0;
	return false;
}


function getLKey(e){keyprs = 1;var kc=(e||window.event).keyCode;if(kc==37||kc==39){LD.stope(e);return false;}}

var imgPreload;
var imgPreloader,ImgW=0,ImgH=0,LF=0;
function GetImageHeight(oImage)
{
	if(TmpImg.src.substring(TmpImg.src.length-oImage.length,TmpImg.src.length)!=oImage){TmpImg.src=oImage;return false;}
	if(TmpImg.complete==false)return(false);
	return TmpImg.height;
}


var resetsize="var L=$id('light_left').style,R=$id('light_right').style,LB=$id('lightbox');L.left='0px';L.width=R.width=R.left=R.left=parseInt(LB.offsetWidth/2)+'px';L.top=R.top=LD.getY($id('light_link'))+'px';L.height=R.height=(LB.offsetHeight-35)+'px';";
var curlt;
function createimg(obj)
{
	var a=$id("light_link"),j=obj;
	if($id("lightboxImage"))a.removeChild($id("lightboxImage"));
	if(!j)j = document.createElement("img");
	j.setAttribute('id','lightboxImage');
	a.appendChild(j);
	return($id("lightboxImage"));
}

function showLightbox(objLink,ty)
{
	var objImage = createimg();
	curlt=objLink.id;
	var objOvl = $id('overlay');
	var oLB = $id('lightbox');
	objImage = $id('lightboxImage');
	var LI = $id('loadingImage');
	var prevM = $id('light_left');
	var nextM = $id('light_right');
	$id('light_neww').href = $(objLink).attr("fullfile")!=""&&(!isUndef($(objLink).attr("fullfile")))?$(objLink).attr("fullfile"):objLink.src;
	ImgW = ImgH = 0;
	LF = 0;

	
	var arrayPageSize = getPageSize();
	var arrayPageScroll = getPageScroll();

	if (LI) {
		LI.style.top = (arrayPageScroll[1] + ((arrayPageSize[3] - 35 - LI.height) / 2) + 'px');
		LI.style.left = (((arrayPageSize[0] - 20 - LI.width) / 2) + 'px');
		LI.style.display = 'block';
	}

	if(ty!="1")
	{
	objOvl.style.height = (arrayPageSize[1] + 'px');
	setOpacity(objOvl,0);
	objOvl.style.display = 'block';
	setOpacity(objOvl,40);
	}

	imgPreload = new Image();

	var loadingImage = HU + 'images/style/0/ajax_loader.gif';
	objImage.src = loadingImage;
	nextM.style.display = prevM.style.display = "none";
	objImage.parentNode.style.cssText="padding:110px 150px;";
	objImage.style.width=objImage.style.height="auto";
	setCenterDiv(oLB);

	imgPreload.onerror=function(){
		LF=0;
		objImage = createimg();
		objImage.src=HU + "images/loadfaild.gif";
		objLink.error=1;
		this.onload();
	};
	imgPreload.onload=function(){
		this.onload=this.onerror=null;
		ImgW = this.width;
		ImgH = this.height;
		var IW,IH;
		IW=ImgW<320?parseInt(320-ImgW)/2:0;
		IH=ImgH<240?parseInt(240-ImgH)/2:0;

		if(objLink.error!=1)
		objImage = createimg(imgPreload);
		objImage.style.zIndex = '200';
		var MaxW=getPageSize()[2];
		if(ImgW>MaxW)
		{
			var zm = (MaxW-50)/ImgW;
			if(Browser.ie&&ImgW<33)
			objImage.style.zoom = parseInt(zm*100) + "%";
			else
			{
				objImage.style.width=parseInt(ImgW*zm)+"px";
				objImage.style.height=parseInt(ImgH*zm)+"px";
			}
		}
	
		objImage.parentNode.style.cssText="padding:" + IW + "px " + IH + "px;";

		var objonload=function(b){
			if(ImgW>MaxW)
			{
				var zm = (MaxW-50)/ImgW;
				if(Browser.ie&&ImgW<33)
				objImage.style.zoom = parseInt(zm*100) + "%";
				else
				{
					objImage.style.width=parseInt(ImgW*zm)+"px";
					objImage.style.height=parseInt(ImgH*zm)+"px";
				}
			}

			var NxtO = light_next(objLink.id);
			var prvO = light_next(objLink.id,"prev");

			prevM.oncontextmenu=nextM.oncontextmenu=function (event) {zoomimg(event,'1');return false;}
			var prevMT = $id('light_prevtxt');
			var nextMT = $id('light_nexttxt');
			if(prvO)
			{
				prevM.className = "light_prev";
				prevM.setAttribute('title','PREV');
				prevMT.onclick=prevM.onclick = function () {showLightbox(prvO,"1"); return false;}
				prevMT.style.display="";
			}
			else
			{
				prevM.className = "light_none";
				prevM.setAttribute('title','close');
				prevM.onclick = function () {hideLightbox(); return false;}
				prevMT.style.display="none";
			}
			if(NxtO)
			{
				nextM.className = "light_next";
				nextM.setAttribute('title','NEXT');
				nextMT.onclick = nextM.onclick = function () {showLightbox(NxtO,"1"); return false;}
				nextMT.style.display="";
			}
			else
			{
				nextM.className = "light_none";
				nextM.setAttribute('title','close');
				nextM.onclick = function () {hideLightbox(); return false;}
				nextMT.style.display="none";
			}
			
			setCenterDiv(oLB);
			if(objLink.error!=1)
			$id("light_info").innerHTML = "WIDTH:" + ImgW  + " HEIGHT:" + ImgH;
			else
			$id("light_info").innerHTML = "bad image.";
		}
		LF=1;
		objonload(objImage);
		
		objImage.border = 0;

		if (LI) {LI.style.display = 'none'; }

		if(ty!="1"&&(Browser.ie6||Browser.is_ie_lower))
		{
			selects = document.getElementsByTagName("select");
		        for (i = 0; i != selects.length; i++) {
		                selects[i].style.visibility = "hidden";
		        }
		}

		oLB.style.display = 'block';
		arrayPageSize = getPageSize();
		objOvl.style.height = (arrayPageSize[1] + 'px');
		if(Browser.ie&&!Browser.ie6&&!Browser.is_ie_lower){pause(250);if(ImgW==0)objonload(objImage);}
		setCenterDiv(oLB);
		eval(resetsize + "setCenterDiv($id('" + oLB.id + "'));L.display=R.display = 'block';");

		if(ty!="1")
		{
			addListener(Browser.ie?document.body:window,"keydown",getLKey);
			addListener(Browser.ie?document.body:window,"keyup",getLKeyup);
		}

		delete imgPreload;
		imgPreload=null;
		delete imgPreload;
		if(Browser.ie)CollectGarbage;
		return false;
	}

	imgPreload.border = 0;
	imgPreload.src = $(objLink).attr("fullfile")!=""&&(!isUndef($(objLink).attr("fullfile")))?$(objLink).attr("fullfile"):objLink.src;
	
}

function hideLightbox()
{
	objOvl = $id('overlay');
	oLB = $id('lightbox');

	setOpacity(objOvl,0);
	objOvl.style.display = 'none';
	oLB.style.display = 'none';

	selects = document.getElementsByTagName("select");
    for (i = 0; i != selects.length; i++) {
		selects[i].style.visibility = "visible";
	}
	addListener(Browser.ie?document.body:window,"keydown",getLKey,1);
	addListener(Browser.ie?document.body:window,"keyup",getLKeyup,1);
}

function light_next(cobj,ty)
{
	var anchors = document.getElementsByTagName("img");

	var f=0,p,d=0;
	for (var i=0; i<anchors.length; i++){
		var anchor = anchors[i];
		if (anchor.getAttribute("src") && (anchor.getAttribute("rel") == "lightbox")){
			d++;
			if(f==1&&ty!="prev"){return(anchor);}
			if(anchor.id==cobj)
			{
				$id('light_index').innerHTML=d;
				if(ty=="prev")return(p);
				if(i<anchors.length-1)f=1;
			}	
			p = anchor;
		}
	}
	return false;
}

function initLightbox()
{
	if (!document.getElementsByTagName){ return; }
	var anchors = document.getElementsByTagName("img");
	var count=0;
	for (var i=0; i<anchors.length; i++){
		var anchor = anchors[i];
		if (anchor.getAttribute("src") && (anchor.getAttribute("rel") == "lightbox")){
			if(anchor.parentNode.tagName.toLowerCase() != "a")
			anchor.onclick = function () {showLightbox(this); return false;}
			else
			{anchor.oncontextmenu = function () {showLightbox(this); return false;};
			anchor.setAttribute('title','right click to view in lightbox.');}
			anchor.style.cursor = "hand";
			anchor.id="lightimg_" + i;
			count++;
		}
	}

	var objBody = document.getElementsByTagName("body").item(0);
	
	var objOvl = document.createElement("div");
	objOvl.setAttribute('id','overlay');
	objOvl.onclick = function () {hideLightbox(); return false;}
	objOvl.style.background = "url(" + HU + "a/inc/pic/overlay.png)";
	objOvl.style.display = 'none';
	objOvl.style.position = 'absolute';
 	objOvl.className = "overlay";
	objBody.insertBefore(objOvl, objBody.firstChild);
	
	var arrayPageSize = getPageSize();
	var arrayPageScroll = getPageScroll();

	imgPreloader = new Image();
	var loadingImage = HU + 'images/style/0/ajax_loader.gif';
	
	imgPreloader.onload=function(){
		this.onload=null;
		var LILink = document.createElement("a");
		LILink.setAttribute('href','#');
		LILink.onclick = function () {hideLightbox(); return false;}
		objOvl.appendChild(LILink);
		
		var LI = document.createElement("img");
		LI.src = loadingImage;
		LI.border = 0;
		LI.setAttribute('id','loadingImage');
		LI.style.position = 'absolute';
		LI.style.zIndex = '150';
		LILink.appendChild(LI);

		delete imgPreloader;
		imgPreloader=null;
		delete imgPreloader;
		if(Browser.ie)CollectGarbage;

		return false;
	}

	imgPreloader.border = 0;
	imgPreloader.src = loadingImage;
	

	var oLB = document.createElement("div");
	oLB.setAttribute('id','lightbox');
	oLB.style.display = 'none';
	oLB.style.position = 'absolute';
	oLB.style.zIndex = '200';
	oLB.className = 'light_box';
	oLB.style.cursor="move"
	oLB.onmousedown=function (event) {LD.move.mousedown(this,event); return false;}
	objBody.insertBefore(oLB, objOvl.nextSibling);

	var lightimg = document.createElement("div");
	lightimg.id = 'light_link';
	lightimg.className = 'light_img';
	lightimg.style.zIndex = '201';
	lightimg.style.background = 'red';
	oLB.appendChild(lightimg);

	var prev = document.createElement("a");
	prev.setAttribute('id','light_left');
	prev.style.display = 'none';
	prev.style.position = 'absolute';
	prev.style.zIndex = '201';

	var nxt = document.createElement("a");
	nxt.setAttribute('id','light_right');
	nxt.style.display = 'none';
	nxt.style.position = 'absolute';
	nxt.style.zIndex = '201';

	lightimg.appendChild(prev);
	lightimg.appendChild(nxt);

	oLB.innerHTML += "<div class=light_top><span>Image <b id=light_index>1</b> of " + count + "</span> <span id=light_info></span><a href=javascript:; id=light_prevtxt class=unsel hidefocus=true>PREV</a> <a href=javascript:; id=light_nexttxt class=unsel hidefocus=true>NEXT</a> <a href=javascript:; target=_blank id=light_neww title=\"open in new window\" class=\"light_neww\"></a> <a href=javascript:; onclick=\"hideLightbox(); return false;\" title=\"close\" class=\"light_close\"></a></div>"

	addzoomEvent($id('light_link'),$id('light_left'),$id('light_right'));
}

function addzoomEvent(o,o1,o2)
{	
	if(Browser.ff)
	{
		o1.addEventListener("DOMMouseScroll", zoomimg, false);
		o2.addEventListener("DOMMouseScroll", zoomimg, false);
		o.addEventListener("DOMMouseScroll", zoomimg, false);
	}
	else
	{
		o.onmousewheel=o2.onmousewheel=o1.onmousewheel= zoomimg;
	}
}
var zoomimg = function(evt,a)
{
	if(LF==0)return false;
	if((ImgW<1||ImgH<1)&!Browser.ie)return;
	var img=$id('lightboxImage');
	var ev = window.event?window.event:evt;
	if(a=="1")
	{
		if(ImgW<33&&Browser.ie)
		img.style.zoom = "100%";
		else
		{img.style.width=ImgW+"px";img.style.height=ImgH+"px";}
		LD.stope(ev);
		eval(resetsize);
		setCenterDiv($id('lightbox'));
		return false;
	}
	var snum = ev.wheelDelta?ev.wheelDelta/12/100:ev.detail/30;
	
	if(ImgW<33&&Browser.ie)/*for ie6.0 32pxwidth*/
	{
		var zoom = parseInt(img.style.zoom,10);
		if (isNaN(zoom)){
			zoom = 100;
		}
		zoom = zoom/100;
		zoom += snum;
		if (zoom>0.1) img.style.zoom = (zoom*100) + "%";
	}
	else
	{
		var zoom = parseInt(img.style.width.toString().replace(/auto/gim,ImgW).replace(/px/gim,""));
		if (isNaN(zoom)){
			zoom = ImgW;
		}
		zoom = zoom/ImgW;
		zoom -= snum;
		if (zoom>0.1&&zoom<2)
		{
			img.style.width=parseInt(ImgW*zoom)+"px";
			img.style.height=parseInt(ImgH*zoom)+"px";
		}
	}
	eval(resetsize);
	setCenterDiv($id('lightbox'));
	LD.stope(ev);
	return false;
}

//lrc start
function lrc_isHighVer() {
	if(!Browser.ie)return false;
	try {
		var x = new ActiveXObject("WMPlayer.OCX");
	} catch (e) {
		return false;
	}
	return true;
}

var lrc_isMH = lrc_isHighVer();

function lrc_getfiledata(url)
{
	if(url=="none"||url=="")return;
	var C=null;
	if(window.XMLHttpRequest)
	{
		C=new XMLHttpRequest()
	}
	else
	{
		if(window.ActiveXObject)
		{
			try
			{
				C=new ActiveXObject("Microsoft.XMLHTTP")
			}
			catch(B)
			{
				C=new ActiveXObject("MSXML.XMLHTTP")
			}
		}
	}
	
	var a = ""
	C.onreadystatechange=function()
	{
		if (C.readyState == 4)
		{
			if (C.status == 200)
			{
				a = C.responseText;
			}
			else
			{
				//"<p>page error: " + C.statusText +"<\/p>";
			}
			delete C;
			C=null;
			if(Browser.ie)CollectGarbage;
		}
	}
	C.open("GET", HU + "a/proxy.asp?u=" + escape(url), false,"","");
	C.setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=gb2312");
	C.send("");
	return(a);
};

//lrc start
function lrc_play(obj,t,auto,width,height)
{
	var o = obj.parentNode;
	if(typeof $.lrc != "undefined")
	{
		if(auto != "yes")$(o).hide();
		lrc_create(o,t,auto,width,height);
	}
	else
	{
		$import(HU+"inc/js/jplayer/css/blue.css","css","");
		$import(HU+"inc/js/jplayer/js/jquery.jplayer.js","js","",function(){
					$import(HU+"inc/js/jplayer/js/lrc.js","js","",function(){
						if(auto != "yes")$(o).hide();
						lrc_create(o,t,auto,width,height);
					})
				}
		);
	}
}

function lrc_close()
{
	$("#jplayer").prev(".lrc_item").show();
	$("#jplayer").remove();
}

function lrc_create(obj,tt,auto,width,height)
{
	if(typeof $(obj).find(".lrc_source").attr("href")=="undefined"){alert('lrc error!');return;}
	if($("#jplayer").length > 0)
	{
		$("#jplayer").prev(".lrc_item").show();
		$("#jplayer").remove();
	}

	var t = tt;
	//t = "M4V";
	var ur=$(obj).find(".lrc_source").attr("href");
	if(t=="other"||t=="lrc")
	{
		tmp = ur.indexOf("?");
		if(tmp>=0)ur=ur.substring(0,tmp);
		ur = ur.replace(/\\/gi,"/");
		tmp = ur.lastIndexOf(".");
		if(tmp>=0)
		t=ur.substring(tmp).replace(/\./,"").toLowerCase();
		switch(t)
		{
			case "wav":
			case "flv":
			case "fla":
			case "mp3":
			case "m4v":
			case "m4a":
			case "oga":
			case "ogv":
			case "webm":
			case "rtmpa":
			case "rtmpv":
			case "m3u8v":
			case "m3uv":
				break;
			case "mp4":
				t="m4v";
				break;
			case "ogg":
				t="ogg";
				break;
			case "f4v":
				t="flv";
				break;
			case "swf":
				t="swf";
				break;
			case "rm":
			case "rmvb":
			case "ra":
			case "ram":
				t="rm";
				break;
			default:
				var tfile = $(obj).find("span").html();
				if(tfile.length>5)
				{
					var t_t = tfile.substring(tfile.length-4,tfile.length).replace(/\./gi,"");
					switch(t_t)
					{
						case "wav":
						case "flv":
						case "fla":
						case "mp3":
						case "m4v":
						case "m4a":
						case "oga":
						case "ogv":
						case "webm":
						case "tmpa":
						case "tmpv":
						case "3u8v":
						case "m3uv":
							t = t_t;
							break;
						case "mp4":
							t="m4v";
							break;
						case "ogg":
							t="ogg";
							break;
						case "f4v":
							t="flv";
							break;
						case "swf":
							t="swf";
							break;
						case "rmvb":
						case "ram":
							t="rm";
							break;
						default:
							t="mp3";
							break;
					}
				}
				else
				{
					t="mp3";
				}
				break;
		}
	}
	var clas;
	switch(t)
	{
		case "lrc":
		case "wav":
		case "mp3":
		case "m4a":
		case "oga":
		case "rtmpa":
		case "ogg":
			clas="jp-jplayer";
			width="";height="";
			break;
		case "flv":
		case "m4v":
		case "ogv":
		case "webm":
		case "rtmpv":
		case "m3u8v":
		case "m3uv":
			clas="jp-video jp-video-360p";
			width="480px";height="270px";
			break;
		case "swf":
			clas="swf";
			break;
		case "rm":
			clas="rm";
			break;
	}
	var str="";
	var _close = '<a href=javascript:; class="lrc_close" onclick="lrc_close();">\u6536\u8D77</a><div class="clear"></div>';

	switch(clas)
	{
		case "jp-jplayer":
		str = '<div id="jplayer">'+_close+'<div id=\"jquery_jplayer_1\" class=\"jp-jplayer\"></div>'+'\n\r';
		str+='<div id="jp_container_1" class="jp-audio">'+'\n\r';
		str+='	<div class="jp-type-single">'+'\n\r';
		str+='		<div class="jp-title">'+'\n\r';
		str+='			<ul>'+'\n\r';
		str+='				<li>audio player '+$(obj).find(".lrc_source span").text()+'</li>'+'\n\r';
		str+='			</ul>'+'\n\r';
		str+='		</div>'+'\n\r';
		str+='		<div class="jp-gui jp-interface">'+'\n\r';
		str+='			<ul class="jp-controls">'+'\n\r';
		str+='				<li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>'+'\n\r';
		str+='				<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>'+'\n\r';
		str+='				<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>'+'\n\r';
		str+='				<li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>'+'\n\r';
		str+='				<li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>'+'\n\r';
		str+='				<li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>'+'\n\r';
		str+='			</ul>'+'\n\r';
		str+='			<div class="jp-progress">'+'\n\r';
		str+='				<div class="jp-seek-bar">'+'\n\r';
		str+='					<div class="jp-play-bar"></div>'+'\n\r';
		str+='				</div>'+'\n\r';
		str+='			</div>'+'\n\r';
		str+='			<div class="jp-volume-bar">'+'\n\r';
		str+='				<div class="jp-volume-bar-value"></div>'+'\n\r';
		str+='			</div>'+'\n\r';
		str+='			<div class="jp-time-holder">'+'\n\r';
		str+='				<div class="jp-current-time"></div>'+'\n\r';
		str+='				<div class="jp-duration"></div>'+'\n\r';

		str+='				<ul class="jp-toggles">'+'\n\r';
		str+='					<li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>'+'\n\r';
		str+='					<li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>'+'\n\r';
		str+='				</ul>'+'\n\r';
		str+='			</div>'+'\n\r';
		str+='		</div>'+'\n\r';
		str+='		<div class="jp-no-solution">'+'\n\r';
		str+='			<span>Update Required</span>'+'\n\r';
		str+='			To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.'+'\n\r';
		str+='		</div>'+'\n\r';
		str+='	</div>'+'\n\r';
		str+='</div>'+'\n\r';
		if(tt=="lrc")
		{
			str+='		<div class="lrc_content"><ul id="lrc_list">'+'\n\r';
			str+='\u70B9\u51FB\u5F00\u59CB\u64AD\u653E\u2026\u2026'+'\n\r</ul></div>';
		}
		str+='</div>'+'\n\r';
		break;
		
		case "swf":
			if(isUndef(width))width=500;
			if(isUndef(height))height=500;
			if($(obj).find(".lrc_source").attr("data-type")=="html5")
			{
				str='<div id="jplayer">'+_close+'<iframe height=498 width=100% src=\"' + ur + '\" frameborder=0 allowfullscreen></iframe>';
			}
			else
			{
				str='<div id="jplayer">'+_close+'<embed src=\"' + ur + '\" quality=high pluginspage=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\" type=\"application/x-shockwave-flash\" allowFullScreen=\"true\" width=\"'+width+'\" height=\"'+height+'\" />';
			}
			str+='</div>';
			break;
		case "rm":
			str='<div id="jplayer">'+_close+'<OBJECT classid=clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA class=OBJECT id=RAOCX width=\"500\" height=\"400\"><param name=SRC value=\"" + ur + "\"><param name=CONSOLE value=\"2423" + ur + "\"><param name=CONTROLS value=imagewindow><param name=AUTOSTART value=" + autoplay + "></OBJECT><br><OBJECT classid=CLSID:CFCDAA03-8BE4-11CF-B84B-0020AFBBCCFA height=32 id=video2 width=\"500\"><param name=SRC value=\"" + ur + "\"><param name=AUTOSTART value=" + autoplay + "><param name=\"numloop\" value=\"" + playcount + "\" /><param name=CONTROLS value=controlpanel><param name=CONSOLE value=\"2423" + ur + "\"></OBJECT>';
			str+='</div>';
			break;
		default:
		str='	<div id="jplayer">'+_close+'<div id="jp_container_1" class="jp-video">';
		str+='<div class="jp-type-single">';
		str+='	<div id="jquery_jplayer_1" class="jp-jplayer"></div>';
		str+='	<div class="jp-gui">';
		str+='		<div class="jp-video-play">';
		str+='			<a href="javascript:;" class="jp-video-play-icon" tabindex="1">play</a>';
		str+='		</div>';
		str+='		<div class="jp-interface">';
		str+='			<div class="jp-progress">';
		str+='				<div class="jp-seek-bar">';
		str+='					<div class="jp-play-bar"></div>';
		str+='				</div>';
		str+='			</div>';
		str+='			<div class="jp-current-time"></div>';
		str+='			<div class="jp-duration"></div>';
		str+='			<div class="jp-controls-holder">';
		str+='				<ul class="jp-controls">';
		str+='					<li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>';
		str+='					<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>';
		str+='					<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>';
		str+='					<li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>';
		str+='					<li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>';
		str+='					<li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>';
		str+='				</ul>';
		str+='				<div class="jp-volume-bar">';
		str+='					<div class="jp-volume-bar-value"></div>';
		str+='				</div>';
		str+='				<ul class="jp-toggles">';
		str+='					<li><a href="javascript:;" class="jp-full-screen" tabindex="1" title="full screen">full screen</a></li>';
		str+='					<li><a href="javascript:;" class="jp-restore-screen" tabindex="1" title="restore screen">restore screen</a></li>';
		str+='					<li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>';
		str+='					<li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>';
		str+='				</ul>';
		str+='			</div>';
		str+='		</div>';
		str+='	</div>';
		str+='	<div class="jp-no-solution">';
		str+='		<span>Update Required</span>';
		str+='		To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.';
		str+='	</div>';
		str+='</div>';
		str+='</div></div>';
		break;
	}
	$(obj).after(str);
	
	if(clas!="swf")lrc_start(obj,t,auto,width,height);
	$("#jplayer").ScrollTo(600);
}

function lrc_start(obj,tt,auto,w,h){
	var t = tt;
	var ur=$(obj).find(".lrc_source").attr("href");
	var setmda = {mp3:ur},filetype=t;
	switch(t)
	{
		case "lrc":
			filetype = "mp3";
			setmda = {mp3:ur};
			break;
		case "mp3":
			setmda = {mp3:ur};
			break;
		case "wav":
			setmda = {wav:ur};
			break;
		case "m4a":
			setmda = {m4a:ur};
			break;
		case "oga":
			setmda = {oga:ur};
			break;
		case "fla":
			setmda = {fla:ur};
			break;
		case "rtmpa":
			setmda = {rtmpa:ur};
			break;
		case "flv":
			setmda = {flv:ur};
			break;
		case "m4v":
			setmda = {m4v:ur};
			break;
		case "mp4":
			setmda = {m4v:ur};
			break;
		case "ogg":
			filetype = "oga";
			setmda = {oga:ur};
			break;
		case "ogv":
			setmda = {ogv:ur};
			break;
		case "webm":
			setmda = {webmv:ur};
			break;
		case "rtmpv":
			setmda = {rtmpv:ur};
			break;
		default:
			filetype = "mp3";
			setmda = {mp3:ur};
			break;
	};
	var size = {};
	if(w!=""&&h!="")
	size = {width:w,height:h,cssClass:"jp-video-270p"};
	$("#jquery_jplayer_1").jPlayer({
		ready: function (event) {
			$(this).jPlayer("setMedia", setmda).jPlayer((auto=="1"||auto=="yes"||auto=="auto")?"play":"pause");
			if(auto=="1"||auto=="yes"||auto=="auto")
			{setTimeout('$("#jquery_jplayer_1").jPlayer("pause").jPlayer("play");',1000);}
			if($(obj).find(".lrc_content")[0])
			if($(obj).find(".lrc_content").text()!==""){
			var txt = "";
			if(!Browser.is_ie_lower)
			{txt = $(obj).find(".lrc_content").text();}
			else{txt = $(obj).find(".lrc_content").html();
			txt = txt.replace(/<br \/>/gi,"\n").replace(/<br\/>/gi,"\n").replace(/<br>/gi,"\n");
			}
				$.lrc.start(txt, function() {
					return time;
				});
				}else{
					$(".content").html("没有字幕");
				}
		},
		timeupdate: function(event) {
				if(event.jPlayer.status.currentTime==0){
					time = "";
				}else {
					time = event.jPlayer.status.currentTime;
				}
				
			},
			play: function(event) {
				//点击开始方法调用lrc。start歌词方法 返回时间time
				
				if(event.jPlayer.status.currentTime==0){
					//$("#jquery_jplayer_1").jPlayer("pause",1); //此行重播将会暂停
				}
				
				if($(obj).find(".lrc_content")[0])
				if($(obj).find(".lrc_content").text()!==""){
			var txt = "";
			if(!Browser.is_ie_lower)
			{txt = $(obj).find(".lrc_content").text();}
			else{txt = $(obj).find(".lrc_content").html();
			txt = txt.replace(/<br \/>/gi,"\n").replace(/<br\/>/gi,"\n").replace(/<br>/gi,"\n");
			
			}
				$.lrc.start(txt, function() {
					return time;
				});
				}else{
					$(".content").html("没有字幕");
				}
			},
			repeat: function(event) {
			  if(event.jPlayer.options.loop) {
				$(this).unbind(".jPlayerRepeat").bind($.jPlayer.event.ended + ".jPlayer.jPlayerRepeat", function() {
				  $(this).jPlayer("play");
				});
			  } else {
				$(this).unbind(".jPlayerRepeat");
			  }
			},
		swfPath: HU+"inc/js/jplayer/js",  		//存放jplayer.swf的决定路径
		solution:"html, flash", //支持的页面
		size:size,
		supplied: filetype
	});
};
//lrc end



$(document).ready(function() {
	$(".a_image").click(function(){
		$(this).attr("src",$(this).attr("data-url"));
	});
});

var mebook = mebook || {};
$.belowthefold = function (element) {
    var fold = $(window).height() + $(window).scrollTop();
    return fold <= $(element).offset().top;
};

$.abovethetop = function (element) {
    var top = $(window).scrollTop();
    return top >= $(element).offset().top + $(element).height();
};

$.inViewport = function (element) {
    return !$.belowthefold(element) && !$.abovethetop(element)
};

mebook.getInViewportList = function () {
    var list = $('.a_image[data-url]'),
        ret = [];
    list.each(function (i) {
        var li = list.eq(i);
        if ($.inViewport(li)) {
if($(list.eq(i)).attr("data-url"))
{$(list.eq(i)).attr("src",$(list.eq(i)).attr("data-url"));
}
$(list.eq(i)).removeAttr('data-url');
        }
    });
};

$(document).ready(function(){
		refreshAll();
	});
	
function refreshAll(){mebook.getInViewportList();		
	setTimeout(refreshAll,1300);
};