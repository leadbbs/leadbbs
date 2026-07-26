/*
	LeadBBS.COM
	2007-08-31
*/
var vnum = 0; //1  forbid play,-2 allow 3 video to play at same time. 0: allow one
var GBL_domain="",DEF_DownKey="";
//lrc start
var lrcnum = 0;
var autoplay = 0; //0.manual play 1.auto play
var playcount = 2; //play loop count:0-100,0=always replay
//lrc end

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

function leadcode(id)
{
	if ($id(id))
	{
		//lrc start
		if(lrcnum>0&&(!$id("aboutplayer1")))lrcnum=0;
		var start_lrcnum = lrcnum;
		//lrc end
		$id(id).innerHTML = convertcode($id(id).innerHTML);
		//lrc start
		for(var i=start_lrcnum+1;i<=lrcnum;i++)
		{
			eval('lrc_obj'+i+' = new lrc_Class($id("lrcdata'+i+'").innerText,"lrc_obj'+i+'",'+i+');');
			eval('lrc_obj'+i+'.lrc_run();');
		}
		//lrc end
	}
}


function leadcodebycom()
{
	var start_lrcnum = lrcnum;
	for(var i=start_lrcnum+1;i<=100;i++)
	{
		if($id("lrcdata"+i))
		{
		eval('lrc_obj'+i+' = new lrc_Class($id("lrcdata'+i+'").innerText,"lrc_obj'+i+'",'+i+');');
		eval('lrc_obj'+i+'.lrc_run();');
		}
		else
		{break;}
	}
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
	return(tmp);
}

function adjustW(obj)
{
	obj.onload = null;
	if(obj.width>520)obj.width=520;
}

function convertupload(id,ty,fname)
{
	var u = HU + "a/file.asp?lid=" + id + "&s=" + DEF_DownKey
	var fstr=(fname.indexOf(".")>=0)?fstr=" download=\""+fname.replace(/\"/g,"")+"\"":"";
	switch(parseInt(ty))
	{
	case 0:
		return("[IMG]" + u + "[/IMG]");
	case 1:
		return("<div class=ubb_box>[FLASH]" + u + "&r=1[/FLASH]<br><br><a href=" + u + "&down=1 target=_blank data-ajax=false" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>\u70b9\u51fb\u4e0b\u8f7dFlash</a></div>");
	case 4:
		return("<div class=ubb_box>[MP=320,68]" + u + "&r=1[/MP]<br><br><a href=" + u + "&down=1 target=_blank data-ajax=false" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>\u70b9\u51fb\u4e0b\u8f7d\u97f3\u9891</a></div>");
	case 5:
		return("<div class=ubb_box>[MP=320,309]" + u + "&r=1[/MP]<br><br><a href=" + u + "&down=1 target=_blank data-ajax=false" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>\u70b9\u51fb\u4e0b\u8f7d\u89c6\u9891</a></div>");
	default:
		return("<a href=" + u + "&down=1 title=\u70b9\u51fb\u4e0b\u8f7d\u9644\u4ef6 target=_blank data-ajax=false" + fstr + "><img src=" + HU + "images/fileType/pubic.gif border=0 align=middle>" + fname + "</a>");
	}
	
}

function convertcode(str)
{
	str = str.replace(/\n\r/g, "");
	str = str.replace(/\r\n/g, "");
	str = str.replace(/\n/g, "");
	str = str.replace(/\ \[\/(td)\]/gim,"&nbsp;[/$1]");
	str = str.replace(/\[code\](.*?)\[\/code\]/gim,function($0,$1){var s = $1;s=s.replace(/\[/g,'&#91;');s=s.replace(/\]/g,'&#93;').replace(/\<br\>/gi,'&nbsp;</span></li>\r\n<li><span>').replace(/\<br \/\>/gi,'</span></li><li><span>');return ("<div class=ubb_code><span class=layer_alertclick><span style=cursor:pointer onclick=copyClipboard('Text',this.parentNode.parentNode.innerText.substring(4,this.parentNode.parentNode.innerText.length),'\u590d\u5236\u6210\u529f','" + HU + "',this)>\u590d\u5236\u4ee3\u7801</span></span><ol id=ubbcode><li><span>"+s+"</span></li></ol></div>")});

	str = str.replace(/\[upload=([0-9]{1,14}),([0-9]{1,1})\](.+?)\[\/upload\]/gim,function($0,$1,$2,$3){return convertupload($1,$2,$3);});
	str = str.replace(/\[em([0-9]{1,4})\]/gi,"<img src=\"" + HU + "images/UBBicon/em$1.GIF\" align=absmiddle>");

	str = str.replace(/\[(\/?(u|b|i|sup|sub|strike|ul|ol|tr|td|pre|p|li|blockquote))\]/gim,"<$1>");
	str = str.replace(/\[td=([0-9]{1,2}),([0-9^\,]{1,2})[\,]?([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,function($0,$1,$2,$3){var s=($3=="")?"":" bgColor="+$3;return("<td colspan=" + $1 + " rowspan=" + $2 + s + ">")});
	str = str.replace(/\[hr\]/gim,"<hr size=1 class=splitline>");
	str = str.replace(/\[(\/?)\*\]/gim,"<$1li>");
	str = str.replace(/\[(\/?)PP\]/gim,"<$1p>");

	str = str.replace(/\[quote\](.*?)\[\/quote\]/gim,"<table border=0 cellspacing=0 cellpadding=0><tr><td><div class=ubb_quote><div class=ubb_quotein><table border=0 cellspacing=0 cellpadding=0><tr><td>$1</td></tr></table></div></div></td></tr></table>");

	str = str.replace(/\[face=(.+?)\]/gim,function($0,$1){return("<font face=\"" + $1 + "\">");});
	str = str.replace(/\[FIELDSET=(.+?)\](.*?)\[\/FIELDSET\]/gim,"<FIELDSET><LEGEND>$1</LEGEND>$2</FIELDSET>");

	str = str.replace(/\[size=([0-9]{1,1})\]/gim,"<font size=\"$1\">");
	str = str.replace(/\[size=([a-z0-9\-\%]{1,25})\]/gim,"<font style=\"font-size:$1;\">");
	str = str.replace(/\[color=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font style=\"color:$1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font style=\"BACKGROUND-COLOR: $1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font style=\"BACKGROUND-COLOR: $1\" color=\"$2\">");
	str = str.replace(/\[\/(color|size|face|font|bgcolor)\]/gim,"</font>");
	str = str.replace(/\[LINE\-HEIGHT=(normal|[\.\%ptx0-9]{1,5})\]/gim,"<span style=\"line-height:$1\">");
	str = str.replace(/\[\/(line\-height)\]/gim,"</span>");
	str = str.replace(/\[(glow|SHADOW)=([0-9]{1,2})[0-9]?,([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3})\](.*?)\[\/(glow|SHADOW)\]/gim,"<div style=\"vertical-align:middle;display: inline-block;*display: inline;zoom:1;filter:glow(color=$3, strength=$4);text-shadow: $2px $2px $4px $3;\" style=\"\">$5</div>");
	str = str.replace(/\[fly\](.*?)\[\/fly\]/gi,"<MARQUEE>$1</MARQUEE>");
	//str = str.replace(/\[light\](.*?)\[\/light\]/gi,"<span style=\"behavior:url(../inc/font.htc)\">$1</span>"); //Í¬lrc³åÍ»
	str = str.replace(/\[email[\=]?(.*?)\](.*?)\[\/email\]/gim,function($0,$1,$2){if($1=="")$1=$2;if($2=="")$2=$1;return("<a href=\"mailto:" + url_filter($1) + "\" data-ajax=false>" + $2 + "</a>")});
	//str = str.replace(/\[email\=?(.+?)*\](.*?)\[\/email\]/gim,function($0,$1,$2){if($2=="")$2=$1;return("<a href=\"mailto:" + url_filter($1) + "\" data-ajax=false>" + $2 + "</a>")});
	//str = str.replace(/\[email\](.*?)\[\/email\]/gi,function($0,$1,$2){return("<a href=\"mailto:" + url_filter($1) + "\" data-ajax=false>" + $1 + "</a>")});

	str = str.replace(/\[align=(left|center|right|justify)\]/gim,"<div style=\"text-align:$1\">");
	str = str.replace(/\[\/align\]/gim,"</div>");
	str = str.replace(/\[(img|imga)\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/(img|imga)\]/gi,function($0,$1,$2,$3){return("<img rel=\"lightbox\" src=\"" + HU + "images/lazy.png\" lazy-src=\"" + url_filter($2+$3) + "\" class=\"a_image\" align=\"absmiddle\" border=\"0\" />")});
	str = str.replace(/\[(img|imga)=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/(img|imga)\]/gi,function($0,$1,$2,$3,$4,$5){return("<img rel=\"lightbox\" src=\"" + HU + "images/lazy.png\" lazy-src=\"" + url_filter($4+$5) + "\" class=\"a_image\" align=\"" + $3 + "\" border=\"" + $2 + "\" />")});
	//str = str.replace(/\[imga\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga\]/gi,function($0,$1,$2){return("<img rel=\"lightbox\" src=\"" + url_filter($1+$2) + "\" class=\"a_image\" align=\"absmiddle\" border=\"0\" />")});
	//str = str.replace(/\[imga=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga\]/gi,function($0,$1,$2,$3,$4){return("<img rel=\"lightbox\" src=\"" + url_filter($3+$4) + "\" class=\"a_image\" align=\"" + $2 + "\" border=\"" + $1 + "\" />")});
	str = str.replace(/\[(img|imga)=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop),([0-9\%]{1,5}),([0-9\%]{1,5})\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/(img|imga)\]/gi,function($0,$1,$2,$3,$4,$5,$6,$7){return("<img rel=\"lightbox\" height=" + $4 + " src=\"" + HU + "images/lazy.png\" lazy-src=\"" + url_filter($6+$7) + "\" class=\"a_image\" width=" + $5 + " align=\"" + $3 + "\" border=\"" + $2 + "\" />")});
	//str = str.replace(/\[imga=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop),([0-9\%]{1,5}),([0-9\%]{1,5})\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga\]/gi,function($0,$1,$2,$3,$4,$5,$6){return("<img rel=\"lightbox\" height=" + $3 + " src=\"" + url_filter($5+$6) + "\" class=\"a_image\" width=" + $4 + " align=\"" + $2 + "\" border=\"" + $1 + "\" />")});

	str = str.replace(/\[MP=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/MP\]/gi,function($0,$1,$2,$3){var u=url_filter($3),w=$1,w="100%",h=$2;if (chklink(u)&&vnum<1){vnum++;return("<span id=mplay" + vnum + "><object align=middle classid=CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6 class=OBJECT id=MediaPlayer" + vnum + " width=\"" + w + "\" height=\"" + h + "\"><param name=ShowStatusBar value=-1><param name=url value=\"" + u + "\" /><embed src=\"" + u + "\" width=\"" + w + "\" height=\"" + h + "\" autostart=" + autoplay + " PlayCount=\"" + playcount + "\" type=video/x-ms-wmv></embed><param name=AUTOSTART value=" + autoplay + " /><param name=\"PlayCount\" value=\"" + playcount + "\" /></object></span><span id=mplayerurl" + vnum + " onclick=\"mpplay(" + vnum + ");\" style=\"display:none;cursor:hand\"><IMG SRC=" + HU + "images/FileType/mp3.gif border=0 align=middle height=16 width=16>" + u + "</span>");} else {vnum++;return("<span id=mplay" + vnum + " style=\"display:none;\"><object align=middle classid=CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6 class=OBJECT id=MediaPlayer" + vnum + " width=\"" + w + "\" height=\"" + h + "\"><param name=ShowStatusBar value=-1 /><param name=url value=\"" + u + "\" /><embed src=\"" + u + "\" width=\"" + w + "\" height=\"" + h + "\" autostart=false type=video/x-ms-wmv></embed><param name=AUTOSTART value=0 /></object></span><span id=mplayerurl" + vnum + " onclick=\"mpplay(" + vnum + ");\" style=\"cursor:hand\"><IMG SRC=" + HU + "images/FileType/mp3.gif border=0 align=middle height=16 width=16>\u5a92\u4f53\u6587\u4ef6</span>");} } );
	
	str = str.replace(/\[RM=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/RM\]/gi,function($0,$1,$2,$3){var u=url_filter($3),w=$1,w="100%",h=$2;if (chklink(u)&&vnum<1){vnum++;return("<OBJECT classid=clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA class=OBJECT id=RAOCX width=\"" + w + "\" height=\"" + h + "\"><param name=SRC value=\"" + u + "\"><param name=CONSOLE value=\"2423" + u + "\"><param name=CONTROLS value=imagewindow><param name=AUTOSTART value=" + autoplay + "></OBJECT><br><OBJECT classid=CLSID:CFCDAA03-8BE4-11CF-B84B-0020AFBBCCFA height=32 id=video2 width=\"" + w + "\"><param name=SRC value=\"" + u + "\"><param name=AUTOSTART value=" + autoplay + "><param name=\"numloop\" value=\"" + playcount + "\" /><param name=CONTROLS value=controlpanel><param name=CONSOLE value=\"2423" + u + "\"></OBJECT>");} else {return("<IMG SRC=" + HU + "images/tc/2.gif border=0 align=middle height=16 width=16>" + getlink(u,"RM\u6587\u4ef6",0));} } );
	str = str.replace(/\[FLASH=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLASH\]/gi,function($0,$1,$2,$3){var u=url_filter($3),w=$1,w="100%",h=$2;if (chklink(u)&&vnum<10){vnum++;return("<embed src=\"" + u + "\" quality=high pluginspage=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\" type=\"application/x-shockwave-flash\" allowFullScreen=\"true\" width=\"" + w + "\" height=\"" + h + "\" />");} else {return("<IMG SRC=" + HU + "images/FileType/swf.gif border=0 align=middle height=16 width=16>" + getlink(u,"Flash\u6587\u4ef6",0));} } );
	str = str.replace(/\[FLASH\](.+?)\[\/FLASH\]/gi,function($0,$1){var u=url_filter($1),w=500,w="100%",h=400;if (chklink(u)&&vnum<10){vnum++;return("<embed src=\"" + u + "\" quality=high pluginspage=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\" type=\"application/x-shockwave-flash\" allowFullScreen=\"true\" width=\"" + w + "\" height=\"" + h + "\" />");} else {return("<IMG SRC=" + HU + "images/FileType/swf.gif border=0 align=middle height=16 width=16>" + getlink(u,"Flash\u6587\u4ef6",0));} } );
	
	str = str.replace(/\[FLV=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLV\]/gi,function($0,$1,$2,$3){var u=url_filter($3),w=$1,w="100%",h=$2;if (vnum<3){vnum++;return("<embed src=\"" + HU + "images/pub/Flvplayer.swf?\" flashvars=\"vcastr_file=" + u + "\" quality=\"high\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" type=\"application/x-shockwave-flash\" allowFullScreen=\"true\" width=\"" + w + "\" height=\"" + h + "\"></embed>");} else {return("<IMG SRC=" + HU + "images/FileType/swf.gif border=0 align=middle height=16 width=16>" + getlink(u,"Flv\u6587\u4ef6",0));} } );

	str = str.replace(/\[url=(.+?)\](.*?)\[\/url\]/gi,function($0,$1,$2){if($2=="")$2=$1;return(getlink(url_filter($1),$2,0))});
	str = str.replace(/\[url\](.+?)\[\/url\]/gi,function($0,$1){return(getlink(url_filter($1),$1,1))});
	
	str = str.replace(/\[nulltable\](.+?)\[\/nulltable\]/gim,"<table border=0 cellspacing=0 cellpadding=0>$1</table>");
	str = str.replace(/\[nulltable=(.+?)\](.+?)\[\/nulltable\]/gim,function($0,$1,$2){return("<table border=0 width=100% cellspacing=0 cellpadding=0 background=\"" + url_filter($1) + "\">" + $2 + "</table>")});
	str = str.replace(/\[nulltr\](.+?)\[\/nulltr\]/gim,"<tr>$1</tr>");
	str = str.replace(/\[nulltd\](.+?)\[\/nulltd\]/gim,"<td>$1</td>");
	str = str.replace(/\[table\](.+?)\[\/table\]/gim,"<table class=anctb>$1</table>");
	str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),([0-9]{1,3}),([0-9\%\.\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " style=\"background-color:" + $6 + ";background-image:" + url_filter($8) + "; border-color: " + $1 + ";\" border=" + $7 + ">" + $9+ "</table>")});
	str = str.replace(/\[sound\](.+?)\[\/sound\]/gim,function($0,$1){var u=url_filter($1);return("<a href=\"" + u + "\" data-ajax=false target=_blank><IMG SRC=" + HU + "images/FileType/mid.gif border=0 alt=\"\u80cc\u666f\u97f3\u4e50\" height=16 width=16></a><bgsound src=\"" + u + "\" loop=-1>")});

	//lrc start
	str = str.replace(/\[lrc=(\/|..\/|http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/)(.+?)\](.+?)\[\/lrc\]/gim,function($0,$1,$2,$3){
		var ur=$1+$2,ext="",st;
		ur=ur.replace(/(^\s*)|(\s*$)/g,"");
		if (ur.length-3>=0 && ur.length>=0 && ur.length-3<=ur.length)
		{
			ext = ur.substring(ur.length-3,ur.length).toLowerCase();
		}
		else{return("");}
		lrcnum++;
		st = '<span id="lrcdata'+lrcnum+'" style="display:none">'+$3+'</span>';
		if(ext==".ra"||ext==".rm"||ext=="ram"||ext=="mvb")
		{
			ext=(lrcnum==1)?"false":"false";
			st += '<span id=isRealPlayer'+lrcnum+'></span><embed id="aboutplayer'+lrcnum+'" autogotourl=false type="audio/x-pn-realaudio-plugin" src="'+ur+'" controls="ControlPanel,StatusBar" width=350 height=68 border=0 autostart='+ext+' loop=true></embed><noembed>please install RealPlayer!</noembed>';
		}
		else
		{
			ext=(lrcnum==1)?"false":"false";
			st += '<span id=isMediaPlayer'+lrcnum+'></span><object id=aboutplayer'+lrcnum+' height=64 width=100% align=baseline border=0'
			if(Browser.ie)
			st += ' classid=CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6';
			else
			st += ' type=application/x-ms-wmp';
			st += '><param name="URL" value="'+ur+'"><param name="autoStart" value="'+ext+'"><param name="invokeURLs" value="false"><param name="playCount" value="100"><param name="defaultFrame" value="datawindow"></OBJECT>';
		}
		
		st += '<div id="lrcwordv'+lrcnum+'" style="clear: both; width: 100%;display: none;">';
		st += '<div style="overflow:hidden;BACKGROUND: #eceded;padding-left:15px;padding-top:2px;BORDER-RIGHT: #b4c2e2 1px solid; BORDER-TOP: #b4c2e2 1px solid; BORDER-LEFT: #b4c2e2 1px solid; height:20px; TEXT-ALIGN: left;FONT-SIZE:9pt;"><div style="float:left">¸è´Ê</div> <div style="float:right;margin-right:5px;color:gray;font:11px Arial;font-family:Tahoma;"> LeadBBS lyric 1.01</div></div>';
		st += '<div style="overflow:hidden;height:260px;BORDER-RIGHT: #b4c2e2 1px solid; BORDER-LEFT: #b4c2e2 1px solid;  BORDER-BOTTOM: #b4c2e2 1px solid; TEXT-ALIGN: left;font-family:Tahoma;position:relative;">';
		st += '<div id="lrcoll'+lrcnum+'" style="left:15px;top:-20px;color:#0080C0; cursor: default;position:absolute;z-index:1;">';
		st += '<table border="0" cellspacing="0" cellpadding="0" width="100%">';
		st += '<tr><td nowrap height="20" id="lrc'+lrcnum+'wt1"></td></tr>';
		st += '<tr><td nowrap height="20" id="lrc'+lrcnum+'wt2"></td></tr>';
		st += '<tr><td nowrap height="20" id="lrc'+lrcnum+'wt3"></td></tr>';
		st += '<tr><td nowrap height="20" id="lrc'+lrcnum+'wt4"></td></tr>';
		st += '<tr><td nowrap height="20" id="lrc'+lrcnum+'wt5"></td></tr>';
		st += '<tr><td nowrap height="20" id="lrc'+lrcnum+'wt6"></td></tr>';
		st += '<tr><td nowrap height="20">';
		st += '<table border="0" cellspacing="0" cellpadding="0" style="color:#0080C0; cursor: default;">';
		st += '<tr><td nowrap height="20"><div id="lrc'+lrcnum+'wt7" style="height:20px;"></div><div id="lrcfilter'+lrcnum+'" style="position:relative; height:0px;top: -20px; z-index:6;filter: alpha(opacity=0);overflow:hidden; width:100%; color:#0000FF; height:20"></div></td></tr>';
		st += '</table>';
		st += '</td></tr>';
		st += '<tr style="position:relative; top: -20px;"><td nowrap height="20">';
		st += '<table border="0" cellspacing="0" cellpadding="0">';
		st += '<tr><td nowrap height="20"><div style="position:relative;height:20px;"><div id="lrcbox'+lrcnum+'" style="position:relative;color:#FF8800;FONT-WEIGHT: bold;height:20px;">\u6b4c\u8bcd\u52a0\u8f7d\u4e2d</div>';
		st += '<div style="word-wrap:normal;white-space:nowrap;position:absolute; top: 0px; z-index:6;color:#0000ff;FONT-WEIGHT: bold;overflow:hidden; height:20px;" id="lrcbc'+lrcnum+'"></div></div>';
		st += '</table>';
		st += '</td></tr>';
		st += '<tr style="position:relative; top: -20px;"><td nowrap height="20" id="lrc'+lrcnum+'wt8"></td></tr>';
		st += '<tr style="position:relative; top: -20px;"><td nowrap height="20" id="lrc'+lrcnum+'wt9"></td></tr>';
		st += '<tr style="position:relative; top: -20px;"><td nowrap height="20" id="lrc'+lrcnum+'wt10"></td></tr>';
		st += '<tr style="position:relative; top: -20px;"><td nowrap height="20" id="lrc'+lrcnum+'wt11"></td></tr>';
		st += '<tr style="position:relative; top: -20px;"><td nowrap height="20" id="lrc'+lrcnum+'wt12"></td></tr>';
		st += '<tr style="position:relative; top: -20px;"><td nowrap height="20" id="lrc'+lrcnum+'wt13"></td></tr></table></div></div></div>';
		return(st);
		});
	//lrc end
	
	str = str.replace(/\[collapse(=[^\]]{1,50})?\]\s*(?:<br\s*\/?>)*\s*(.+?)\s*(?:<br\s*\/?>)*\s*\[\/collapse\]/gi,function($0,$1,$2){
		if ($1)$1='<b class="grayfont">'+$1.substr(1)+' ...</b>'
		else $1 = '<b class="grayfont">µã»÷ÏÔÊ¾Òþ²ØµÄÄÚÈÝ ...</b>'
		return "<div style='border-top:1px solid #fff;border-bottom:1px solid #fff'><span style='cursor:pointer;font-size:12px;line-height:normal;display:inline-block;padding:2px 5px 0px 5px;margin-right:5px;' onclick='this.parentNode.style.display=\"none\";this.parentNode.nextSibling.style.display=\"block\";'><b>+</b>"+$1+"</span></div><div style='border-top:1px solid #fff;border-bottom:1px solid #fff;display:none'>"+$2+"</div>"
		});
	str = str.replace(/\[@(.{2,20}?)\]/gi,function($0,$1){ return" <a href='"+HU+"user/lookuserinfo.asp?name="+encodeURIComponent($1)+"' data-ajax=false class='username'>@"+$1+"</a> " } );//[@]

	str = str.replace(/( |\n|\r|\t|\v|\<br\>|\uff1a|\:|\u3000)(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2,$3){var u=$2;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return($1+getlink(url_filter(u+$3),$2+$3,0));});
	str = str.replace(/^(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2){var u=$1;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return(getlink(url_filter(u+$2),$1+$2,0));});
	str = lead_multtb(str);
	return str;
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
	str = str.replace(/\[email=(.+?)\](.+?)\[\/email\]/gi,function($0,$1,$2){return("<a href=\"mailto:" + url_filter($1) + "\" data-ajax=false>" + $2 + "</a>")});
	str = str.replace(/\[email\](.+?)\[\/email\]/gi,function($0,$1,$2){return("<a href=\"mailto:" + url_filter($1) + "\" data-ajax=false>" + $1 + "</a>")});

	str = str.replace(/\[align=(left|center|right|justify)\]/gim,"<div style=\"text-align:$1\">");
	str = str.replace(/\[\/align\]/gim,"</div>");
	str = str.replace(/\[img\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/img\]/gi,function($0,$1,$2){return("<img src=\"" + url_filter($1+$2) + "\" align=middle border=0 onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});
	str = str.replace(/\[img=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/img\]/gi,function($0,$1,$2,$3,$4){return("<img src=\"" + url_filter($3+$4) + "\" align=" + $2 + " border=\"" + $1 + "\" onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});
	str = str.replace(/\[imga\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga\]/gi,function($0,$1,$2){return("<img src=\"" + url_filter($1+$2) + "\" style=\"CURSOR: hand\" onclick=\"javascript:window.open(this.src);\" align=middle border=0 onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});
	str = str.replace(/\[imga=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga\]/gi,function($0,$1,$2,$3,$4){return("<img src=\"" + url_filter($3+$4) + "\" align=\"" + $2 + "\" border=\"" + $1 + "\" style=\"CURSOR: hand\" onclick=\"javascript:window.open(this.src);\" onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});
	str = str.replace(/\[img=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop),([0-9\%]{1,5}),([0-9\%]{1,5})\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/img\]/gi,function($0,$1,$2,$3,$4,$5,$6){return("<img height=" + $3 + " src=\"" + url_filter($5+$6) + "\" width=" + $4 + " align=\"" + $2 + "\" border=\"" + $1 + "\" onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});
	str = str.replace(/\[imga=([0-9]{1,2}),(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop),([0-9\%]{1,5}),([0-9\%]{1,5})\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga\]/gi,function($0,$1,$2,$3,$4,$5,$6){return("<img height=" + $3 + " src=\"" + url_filter($5+$6) + "\" width=" + $4 + " align=\"" + $2 + "\" border=\"" + $1 + "\" onclick=\"javascript:window.open(this.src);\" onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});

	str = str.replace(/\[url=(.+?)\](.+?)\[\/url\]/gi,function($0,$1,$2){return(getlink(url_filter($1),$2,0))});
	str = str.replace(/\[url\](.+?)\[\/url\]/gi,function($0,$1){return(getlink(url_filter($1),$1,1))});

	str = str.replace(/( |\n|\r|\t|\v|\<br\>|\uff1a|\:|\u3000)(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2,$3){var u=$2;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return($1+getlink(url_filter(u+$3),$2+$3,0));});
	str = str.replace(/^(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000]*)/gi,function($0,$1,$2){var u=$1;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return(getlink(url_filter(u+$2),$1+$2,0));});

	return str;
}

//check safe link.
function chklink(ul)
{
	if(ul.substr(0,3) == '../'||ul.substr(0,1) == '/'){return 1;}
	var nn,ur,t,ur2;
	ur = ul;
	ur = ur.replace(/\|/gi,"").replace(/\\/gi,"\/");
	t = ur.match(/(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/)([a-z0-9\.\-]*)/);
	if (t && t[2])
	ur = t[2];
	nn = ur.split(".");
	if(nn.length>2)
	ur=(nn[nn.length-2]+"."+nn[nn.length-1]);
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
function getlink(url,nm,f)
{
var ed = ">",t = '',t2 = '',u=url.replace(/(^\s*)/g,"");
if (f == 1){t2 = "<img src=" + HU + "images/tc/5.gif border=0 align=absmiddle>";}
if (chklink(u) == 0)
	{
		t = "<div class=altlink><span class=grayfont>" + (u.length<101?u:u.substring(0,70)+"......"+u.substring(u.length-24,u.length)) + "</span><br>\u8bbf\u95ee\u7f51\u5740\u8d85\u51fa\u672c\u7ad9\u8303\u56f4\uff0c\u4e0d\u80fd\u786e\u5b9a\u662f\u5426\u5b89\u5168 <br><a href=\"" + u + "\" onclick='$id(\"a_alt_link\").style.display=\"none\";' data-ajax=false target='_blank'>\u7ee7\u7eed\u8bbf\u95ee</a> <a href='#ntg' data-ajax=false onclick='$id(\"a_alt_link\").style.display=\"none\";'>\u53d6\u6d88\u8bbf\u95ee</a></div>";
		
		ed = " class=layer_alertclick onclick=\"layer_view('" + $replace($replace(t,String.fromCharCode(39),'\'+String.fromCharCode(39)+\''),'"','\'+String.fromCharCode(34)+\'') + "','','','','a_alt_link','','',0,'',0,-1314,'',event);return false;\"" + ed;
	}
	//return (t2 + "<a href=\"" + u + "\" data-ajax=false target='_blank' " + ed + nm + "</a>");
	//return (t2 + nm + "" +  u.replace(/w/g,"\u0064") + "]");
	return (t2 + nm);
}

function lead_multtb(s)
{
	var str = s;
	var oldstr = "",tmp;
	tmp = str.toLowerCase();
	while(oldstr != str)
	{	oldstr = str;
		str = str.replace(/\[table\](.+?)\[\/table\]/gim,"<table class=anctb>$1</table>");
		str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),([0-9]{1,3}),([0-9\%\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table borderColor=" + $1 + " cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " bgColor=" + $6 + " background=\"" + url_filter($8) + "\" border=" + $7 + ">" + $9+ "</table>")});
		tmp = str.toLowerCase();
	}
	return(str);
}


$(document).ready(function() {
	$(".a_image").click(function(){
		$(this).attr("src",$(this).attr("lazy-src"));
	});
});

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
	C.open("GET", HU + "a/proxy.asp?u=" + encodeURIComponent(url), false,"","");
	C.setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=gb2312");
	C.send("");
	return(a);
};

function lrc_Class(tt,objstr,No)
{
	this.objstr = objstr;
	this.No = No;

	this.lrc_0;
	this.lrc_main;
	this.lrc_1;
	this.lrc_min;
	this.lrc_pType = null;

	this.inr = [];
	this.min = [];

	this.oTime = 0;

	this.dts = -1;
	this.dte = -1;
	this.dlt = -1;
	this.ddh;
	this.fjh;

	if($id('isMediaPlayer'+this.No))
	{
		this.lrc_pType = lrc_isMH ? "MPH" : "MPL";
	}
	else if($id('isRealPlayer'+this.No)){this.lrc_pType="RP"}

	if(tt.substr(0,4).toUpperCase() == "FTP:" || tt.substr(0,4).toUpperCase() == "HTTP")
	{
		tt = lrc_getfiledata(tt);
	}
	if(tt!=""){if($id('lrcwordv'+this.No))$id('lrcwordv'+this.No).style.display="";}else{return;}

	//if($id("lrcbc"+this.No))$id("lrcbc"+this.No).style.width = "300px";

	if(/\[offset\:(\-?\d+)\]/i.test(tt))
	this.oTime = RegExp.$1/1000;
 
	tt = tt.replace(/\[\:\][^$\n]*(\n|$)/g,"$1");
	tt = tt.replace(/\[[^\[\]\:]*\]/g,"");
	tt = tt.replace(/\[[^\[\]]*[^\[\]\d]+[^\[\]]*\:[^\[\]]*\]/g,"");
	tt = tt.replace(/\[[^\[\]]*\:[^\[\]]*[^\[\]\d\.]+[^\[\]]*\]/g,"");
	tt = tt.replace(/<[^<>]*[^<>\d]+[^<>]*\:[^<>]*>/g,"");
	tt = tt.replace(/<[^<>]*\:[^<>]*[^<>\d\.]+[^<>]*>/g,"");

	while(/\[[^\[\]]+\:[^\[\]]+\]/.test(tt))
	{
		tt = tt.replace(/((\[[^\[\]]+\:[^\[\]]+\])+[^\[\r\n]*)[^\[]*/,"\n");
		var zzzt = RegExp.$1;
		/^(.+\])([^\]]*)$/.exec(zzzt);
		var ltxt = RegExp.$2;
		var eft = RegExp.$1.slice(1,-1).split("][");
		for(var ii=0; ii<eft.length; ii++)
		{
			var sf = eft[ii].split(":");
			var tse = parseInt(sf[0],10) * 60 + parseFloat(sf[1]);
			var sso = { t:[] , w:[] , n:ltxt }
			sso.t[0] = tse-this.oTime;
			this.inr[this.inr.length] = sso;
		}
	}
	this.inr = this.inr.sort( function(a,b){return a.t[0]-b.t[0];} );

	for(var ii=0; ii<this.inr.length; ii++)
	{
		while(/<[^<>]+\:[^<>]+>/.test(this.inr[ii].n))
		{
			this.inr[ii].n = this.inr[ii].n.replace(/<(\d+)\:([\d\.]+)>/,"%=%");
			var tse = parseInt(RegExp.$1,10) * 60 + parseFloat(RegExp.$2);
			this.inr[ii].t[this.inr[ii].t.length] = tse-this.oTime;
		}
		if($id("lrcbc"+this.No))$id("lrcbc"+this.No).innerHTML = "<font>"+ this.inr[ii].n.replace(/&/g,"&").replace(/</g,"<").replace(/>/g,">").replace(/%=%/g,"</font><font>") +"</font>";
		if($id("lrcbc"+this.No))
		{
			var fall = $id("lrcbc"+this.No).getElementsByTagName("font");
			for(var wi=0; wi<fall.length; wi++)
				this.inr[ii].w[this.inr[ii].w.length] = fall[wi].offsetWidth;
		}
		if($id("lrcbc"+this.No))this.inr[ii].n = $id("lrcbc"+this.No).innerText;
	}

	for(var ii=0; ii<this.inr.length-1; ii++)
		this.min[ii] = Math.floor((this.inr[ii+1].t[0]-this.inr[ii].t[0])*10);
	this.min.sort(function(a,b){return a-b});
	this.lrc_min = this.min[0]/2;

	this.run = function(tme)
	{
		if(tme<this.dts || tme>=this.dte)
		{
			var ii;
			for(ii=this.inr.length-1; ii>=0 && this.inr[ii].t[0]>tme; ii--){}
			if(ii<0) return;
			this.ddh = this.inr[ii].t;
			this.fjh = this.inr[ii].w;
			this.dts = this.inr[ii].t[0];
			if(ii<this.inr.length-1)this.dte = (ii<this.inr.length-1)?this.inr[ii+1].t[0]:$id("aboutplayer"+this.No).currentMedia.duration;

			var L="lrc"+this.No+"wt";
			//lrc_setc(L+"1",this.retxt(ii-7));
			lrc_setc(L+"1","");
			lrc_setc(L+"2",this.retxt(ii-6));
			lrc_setc(L+"3",this.retxt(ii-5));
			lrc_setc(L+"4",this.retxt(ii-4));
			lrc_setc(L+"5",this.retxt(ii-3));
			lrc_setc(L+"6",this.retxt(ii-2));
			lrc_setc(L+"7",this.retxt(ii-1));
			lrc_setc("lrcfilter"+this.No,this.retxt(ii-1));
			lrc_setc(L+"8",this.retxt(ii+1));
			lrc_setc(L+"9",this.retxt(ii+2));
			lrc_setc(L+"10",this.retxt(ii+3));
			lrc_setc(L+"11",this.retxt(ii+4));
			lrc_setc(L+"12",this.retxt(ii+5));
			//lrc_setc(L+"13",this.retxt(ii+6));
			lrc_setc(L+"13","");
			this.print(this.retxt(ii));
			if(this.dlt==ii-1)
			{
				clearTimeout(this.lrc_0);
				if($id("lrcoll"+this.No)){if($id("lrcoll"+this.No).style.pixelTop!=0) $id("lrcoll"+this.No).style.top = 0+"px";}
				this.lrc_golrcoll(0);
				clearTimeout(this.lrc_1);
				setOpacity($id("lrcfilter"+this.No),100)
				this.lrc_golrcolor(0);
			}
			else if($id("lrcoll"+this.No))
			{
				if(parseInt($id("lrcoll"+this.No).style.top)!=-20)
				{
					clearTimeout(this.lrc_0);
					$id("lrcoll"+this.No).style.top = -20+"px";
					clearTimeout(this.lrc_1);
					setOpacity($id("lrcfilter"+this.No),0)
				}
			}
			this.dlt = ii;
		}
		var bbw = 0;
		var ki;
		for(ki=0; ki<this.ddh.length && this.ddh[ki]<=tme; ki++)
			bbw += this.fjh[ki];
		var kt = ki-1;
		var sc = ((ki<this.ddh.length)?this.ddh[ki]:this.dte) - this.ddh[kt];
		var tc = tme - this.ddh[kt];
		if(sc>0)bbw -= this.fjh[kt] - tc / sc * this.fjh[kt];
		if($id("lrcbox"+this.No)&&$id("lrcbc"+this.No))
		{
			if(bbw>$id("lrcbox"+this.No).offsetWidth)
				bbw = $id("lrcbox"+this.No).offsetWidth;
			//if(Browser.ie8)
			//$id("lrcbc"+this.No).style.width = "100%";
			//else
			$id("lrcbc"+this.No).style.width = Math.round(bbw)+"px";
		}
	}

	this.retxt = function(i)
	{
		return (i<0 || i>=this.inr.length)?"":this.inr[i].n;
	}

	this.print = function(txt)
	{
		lrc_setc("lrcbox"+this.No,txt);
		lrc_setc("lrcbc"+this.No,txt);
	}

	//if(Browser.ie)
	this.print("\u6b4c\u8bcd\u8f7d\u5165\u4e2d....");
	//else
	//{this.print("\u60a8\u7684\u6d4f\u89c8\u5668\u4e0d\u652f\u6301LRC\u540c\u6b65.");}
	var L="lrc"+this.No+"wt";
	lrc_setc(L+"1","");
	lrc_setc(L+"2","");
	lrc_setc(L+"3","");
	lrc_setc(L+"4","");
	lrc_setc(L+"5","");
	lrc_setc(L+"6","");
	lrc_setc(L+"7","");
	lrc_setc("lrcfilter"+this.No,"");
	lrc_setc(L+"8","");
	lrc_setc(L+"9","");
	lrc_setc(L+"10","");
	lrc_setc(L+"11","");
	lrc_setc(L+"12","");
	lrc_setc(L+"13","");

	this.lrc_golrcoll = function(s)
	{
		clearTimeout(this.lrc_0);
		if($id("lrcoll"+this.No))$id("lrcoll"+this.No).style.top = -(s++)*2 +"px";
		if(s<=9)
			this.lrc_0 = setTimeout(this.objstr + ".lrc_golrcoll("+s+")",this.lrc_min*10);
	}
	this.lrc_run = function()
	{
		clearTimeout(this.lrc_main);
		if($id("aboutplayer"+this.No))this.run(lrc_getCurrentPosition($id("aboutplayer"+this.No),this.lrc_pType));
		if(arguments.length==0)this.lrc_main = setTimeout(this.objstr + ".lrc_run()",100);
	}
	

	this.lrc_golrcolor = function(t)
	{
		clearTimeout(this.lrc_1);
		setOpacity($id("lrcfilter"+this.No),110-(t++)*10);
		if(t<=10)
		this.lrc_1 = setTimeout(this.objstr + ".lrc_golrcolor("+t+")",this.lrc_min*10);
	}
}
function lrc_setc(nm,st)
{
	if($id(nm))$id(nm).innerText = st;
}

function lrc_getCurrentPosition(A,ty)
{
	try
	{
		if(ty=="MPH"||!isUndef(A.controls))
		{
			return isUndef(A.controls.currentPosition)?0:A.controls.currentPosition;
		}
		else
		{
			if(ty=="MPL")
			{
				return isUndef(A.CurrentPosition)?0:A.CurrentPosition;
			}
			else
			{
				if(ty=="RP")
				{
					return isUndef(A.GetPosition())?0:A.GetPosition()/1000;
				}
				else
				{
				}
			}
		}
		return 0;
	}catch (e) {
		return 0;
	}
	return 0;
}
//lrc end