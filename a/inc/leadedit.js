/*
	LeadBBS.COM
	2007-08-31
*/
var edt_heigh = 220,edt_mode = 1,edt_initdone = 0;
var edt_txtobj;
var edt_htmobj = edt_doc = iframe = edt_win = null;

var edt_escfg = 0;

function edt_disable_esc()
{
	if(event.keyCode==27)return(false);
}
function edt_disablesc()
{
	if(edt_escfg==1)return;
	edt_escfg = 1;
	if (document.all)    
		$id('body').attachEvent("onkeydown",edt_disable_esc);    
	else    
		$id('body').addEventListener("onkeydown",edt_disable_esc,false);
}

function edt_init()
{
	edt_txtobj = $id('Form_Content');
	edt_disablesc();
}

function format(what,opt) {
	if (opt=="RemoveFormat") {
		what=opt;
		opt=null;
	}
	if (opt==null) edt_doc.execCommand(what,false,true);
	else edt_doc.execCommand(what,"",opt,true);
}

function insertHTML2(ty,html,htm2,htm3)
{
	var obj=$id('LEADEDT').document;
	edt_win.focus();
	var tmp1,tmp2="",tmp3="";
	tmp1 = html;
	if(ty!=2)
	{
		if(ty==3)
		{
			if(!isUndef(htm2))
			{
				tmp1 = html + ":" + htm2;
			}
			tmp1 = "<span style=\"" + tmp1 + "\">";
			tmp2 = "</span>";
		}
		else
		{
			if(!isUndef(htm3))
			{
				tmp1 = html + "=" + htm3;
			}
			if(!ty)tmp1 = "[" + tmp1 + "]";
			if(!isUndef(htm2))
			{
				if(!ty)tmp2 = "[" + htm2 + "]";
			}
		}
	}
	switch(html.toLowerCase())
	{
	case "b":	format('bold');return;
			break;
	case "i":	format('italic');return;
			break;
	case "u":	format('underline');return;
			break;
	case "pp":	format('InsertParagraph');return;
			break;
	case "sup":	format('superscript');return;
			break;
	case "sub":	format('subscript');return;
			break;
	case "color":	format('ForeColor',htm3);return;
			break;
	case "hilitecolor":
	case "backcolor":
			format(html,htm3);return;
			break;
	case "align":
			tmp3=htm3.toLowerCase();
			if(tmp3=="center"){format("justifycenter");}
			else if(tmp3=="left"){format("justifyleft");}
			else if(tmp3=="right"){format("justifyright");}
			else if(tmp3=="justify"){format("JustifyFull");}
			return;
			break;
	case "face":
			format("fontname",htm3);
			return;
			break;
	//case "size":
	//		format("fontsize",htm3);
	//		return;
	//		break;
	case "formatblock":
			format("FormatBlock",htm3);
			return;
			break;
	case "saveas":
			if(!Browser.ie){alert("\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u6b64\u529f\u80fd.");return;}
			format("SaveAs","leadedit.htm");
			return;
			break;
	case "cut":
	case "copy":
	case "paste":
	case "delete":
	case "removeformat":
	case "undo":
	case "redo":
	case "insertorderedlist":
	case "insertunorderedlist":
	case "selectall":
	case "unselect":
	case "unlink":
			format(html);
			return;
			break;
	case "strike":
			format("StrikeThrough");
			return;break;
	case "hr":
			format('InsertHorizontalRule');
			return;break;
	}
	if(!Browser.ie)
	{
		obj=edt_doc;
		var sl = edt_win.getSelection();
		var rg = sl ? sl.getRangeAt(0) : edt_doc.createRange();
		if(!(Browser.ie11 || Browser.ie12))
		{
			edt_doc.execCommand('insertHTML', false, tmp1+edt_readNodes(rg.cloneContents(), false)+tmp2);
		}
		else
		{
		
			var Ld = 'Ld' + Math.random();
		var hs = '<span id="' + Ld + '">' + tmp1+edt_readNodes(rg.cloneContents(), false)+tmp2 + '</span>';
		//var hs = tmp1+edt_readNodes(rg.cloneContents(), false)+tmp2;
		var selection = edt_win.getSelection();
		var range = selection.getRangeAt(0);
		
		range.deleteContents();
		var fragment = range.createContextualFragment(hs);
		var dd = range.insertNode(fragment);
		var tmp = edt_doc.getElementById(Ld).firstChild;
		//range.setStart(tmp, 1);
		//range.setEnd(tmp, 1);
		range.setStartAfter(tmp);
		range.collapse(true);
		selection.removeAllRanges();
		selection.addRange(range);
		}
		try{
		edt_doc.focus();
		}
		catch(e){}
	}
	else
	{
		obj=edt_doc;
		edt_win.focus();
		if(!isUndef(obj.selection) && obj.selection.type != 'Text' && obj.selection.type != 'None')
		{
			obj.selection.clear();
		}
		var selrang = obj.selection.createRange();

		var str = tmp1 + selrang.htmlText + tmp2;
		if(edt_win.pos)
		edt_win.pos.pasteHTML(str) ; 
		else
		selrang.pasteHTML(str) ; 
		if((str!=tmp1+tmp2) && str.indexOf('<') == -1 && str.indexOf('\n') == -1 && str.indexOf('\r') == -1) {
			selrang.moveStart('character', -str.length);
			selrang.select();
		}
		edt_doc.focus();
	}
}

var __UndoBookmark__;
function initBookMark() {
if(Browser.ie||Browser.ie11||Browser.ie12)
{
	edt_doc.onbeforedeactivate = function()
	{
		if (edt_win.getSelection) {
                var selection = edt_win.getSelection ();
                if (selection.rangeCount > 0) {
                    __UndoBookmark__ = selection.getRangeAt(0);
                }
            }
            else {
                if (edt_doc.selection) {   // Internet Explorer
                    var range = edt_doc.selection.createRange ();
                    __UndoBookmark__ = range.getBookmark ();
                }
            }
	};

	edt_doc.onactivate = function () {
		
		if (edt_win.getSelection) {
                if(__UndoBookmark__)
                {edt_win.getSelection ().removeAllRanges ();
             edt_win.getSelection ().addRange (__UndoBookmark__);}
            }
            else {
                if (edt_doc.body.createTextRange) {    // Internet Explorer
                    if(__UndoBookmark__)
                    {rangeObj = edt_doc.body.createTextRange ();
                    rangeObj.moveToBookmark (__UndoBookmark__);
                 rangeObj.select ();}
                }
            }
	}
	}
}


function edt_readNodes(nod, roottag)
{
	var str = "";
	var moz = /_moz/i;

	switch(nod.nodeType)
	{
		case Node.ELEMENT_NODE:
		case Node.DOCUMENT_FRAGMENT_NODE:
			var flag;
			if(roottag)
			{
				flag = !nod.hasChildNodes();
				str = '<' + nod.tagName.toLowerCase();
				var attr = nod.attributes;
				for(var i = 0; i < attr.length; ++i)
				{
					var a = attr.item(i);
					if(!a.specified || a.name.match(moz) || a.value.match(moz))
					{
						continue;
					}
					str += " " + a.name.toLowerCase() + '="' + a.value + '"';
				}
				str += flag ? " />" : ">";
			}
			for(var n = nod.firstChild; n; n = n.nextSibling)
			{
				str += edt_readNodes(n, true);
			}
			if(roottag && !flag)
			{
				str += "</" + nod.tagName.toLowerCase() + ">";
			}
			break;
		case Node.TEXT_NODE:
			str = nod.data;
			break;
	}
	return str;
}

function editor_saveRange()
{
	if(Browser.ie)
	{
	}
}

function addcontent(ty,s1,s2,s3)
{
	if(edt_mode == 1)
	{
		if(ty==2){alert("\u6587\u672c\u6a21\u5f0f\u65e0\u6cd5\u4f7f\u7528\u6b64\u529f\u80fd\uff0e");return;}
		var str1=s1,str2="";
		
		if(ty==3)
		{
			if(!isUndef(s2))
			{
				tmp1 = s1 + "=" + s2;
			}
			str1 = "[" + tmp1 + "]";
			str2 = "[/" + s1 + "]";
		}
		else
		{	
			if(!isUndef(s3))
			{
				str1 = s1 + "=" + s3;
			}
			if(!ty)str1="["+str1+"]";
			if(!isUndef(s2))
			{
				if(!ty)str2 = "[" + s2 + "]";
			}
		}
		
		var str=str1 + str2;
		var obj=$id('Form_Content');
		obj.focus();

		if(!isUndef(obj.selectionStart)) 
		{
			str = str1 + obj.value.substr(obj.selectionStart,obj.selectionEnd-obj.selectionStart) + str2;
			obj.value = obj.value.substr(0, obj.selectionStart) + str + obj.value.substr(obj.selectionEnd);
		}
		else if ((document.selection)&&(document.selection.type== "Text"))
		{
			var range = document.selection.createRange();
			var ch_text = range.text;
			range.text = str1 + ch_text + str2;
		} 
		else
		{
			if (obj.createTextRange && obj.caretPos)
			{
				var caretPos = obj.caretPos;
				caretPos.text = str1 + caretPos.text + str2;
				obj.focus();
			}
			else{obj.value+=str;obj.focus();}
		}
	}
	else{insertHTML2(ty,s1,s2,s3);return;}
}
	
function insert(what) {

	switch(what){
	case "nowdate":
		var d = new Date();
		addcontent(1,d.toLocaleDateString());
		break;
	case "nowtime":
		var d = new Date();
		addcontent(1,d.toLocaleTimeString());
		break;
	case "br":
		addcontent(2,"<br>")
		break;
	case "code":
		addcontent(0,'CODE','/CODE');
		break;
	case "quote":
		addcontent(0,'QUOTE','/QUOTE');
		break;
	case "fly":
		addcontent(0,'FLY','/FLY');
		break;
	default:
		addcontent(0,'face','/face',what);
		break;
	}
	sel=null;
}

function ShowDialog(url, width, height, optValidate)
{
	//$id('LEADEDT').focus();
	var arr = showModalDialog(url, window, "dialogWidth:" + width + "px;dialogHeight:" + height + "px;help:no;scroll:no;status:no;");
	//$id('LEADEDT').focus();
	if(edt_mode)
	{
		edt_txtobj.focus();
	}
	else
	{
		edt_win.focus();
	}
}

function edt_htadd()
{
	if(edt_heigh<560)
	{
	edt_heigh+=160;
	edt_txtobj.style.height=edt_heigh + 'px';
	if(edt_htmobj)edt_htmobj.style.height=edt_heigh + 'px';
	}
}
function edt_htsub()
{
	if(edt_heigh>100)
	{
	edt_heigh-=40;
	edt_txtobj.style.height=edt_heigh + 'px';
	if(edt_htmobj)edt_htmobj.style.height=edt_heigh + 'px';
	}
}
function edt_htresume()
{
	edt_heigh = 220;
	edt_txtobj.style.height = '220px';
	if(edt_htmobj)edt_htmobj.style.height='220px';
}

function edt_icon(t)
{
	if(!edt_mode)
	{
		addcontent(2,"<IMG SRC=../images/UBBicon/em" + t + ".GIF border=0 emotid=\"" + t + "\">");
	}
	else
	{
		addcontent(1,"[EM" + t + "]");
	}
}

function edit_clear()
{
	if(!isUndef(edt_txtobj))edt_txtobj.value = "";
	if(!isUndef(edt_doc))$(edt_doc.body).empty();
}

function edt_htmlMode()
{
	if(!edt_mode)return;
	edt_mode = 0;
	
	var existf = 0;
	if(!$("#LEADEDT")[0])
	{
	iframe = document.createElement('iframe');
	iframe.style.display="none";
	edt_htmobj = edt_txtobj.parentNode.appendChild(iframe);
	}
	else
	{
		edt_htmobj = $("#LEADEDT")[0];
		existf = 1;
	}
	edt_htmobj.id = 'LEADEDT';

	$(edt_htmobj).attr("tabindex","2");
	
	edt_win = edt_htmobj.contentWindow;
	edt_doc = edt_htmobj.contentWindow.document;

	edt_htmobj.style.width='100%';
	
	if(existf==0)
	{
	edt_htmobj.style.height=edt_heigh + 'px';
	edt_txtobj.style.height=edt_heigh + 'px';
	}
	else
	{
		edt_htmobj.style.height=edt_txtobj.style.height=$(".editor").css("height");
	}
	
	edt_htmobj.style.padding='0px';
	edt_htmobj.style.border='0px';
	edt_htmobj.style.marginwidth='0px';
	edt_txtobj.style.display='none';
	edt_htmobj.style.display='';
	
	edt_doc.designMode = 'on';
	edt_doc.contentEditable = true;
	edt_doc.open('text/html', 'replace');
	var codemode = edt_getcodemode();
	if(codemode==1)
	edt_doc.write(edt_txtobj.value);
	else
	edt_doc.write(edt_bbscode(edt_txtobj.value));
	edt_doc.close();
	//if(Browser.is_ie)edt_doc.createStyleSheet().cssText = document.styleSheets['css'].cssText + '\n p { margin: 0px;}';
	if(Browser.ie)edt_doc.createStyleSheet().cssText += '\n * { line-height:1.5em;}\n p { margin: 0px 0px 5px 0px;line-height:1.5em;}';
	edt_doc.body.style.wordBreak = "break-all";
	edt_doc.body.style.wordWrap = "break-word";
	edt_doc.body.style.border = '0px';
	edt_doc.body.style.fontSize = "9pt";
	edt_doc.body.style.fontFamily = "宋体";
	edt_doc.body.style.margin = "0";
	edt_doc.body.style.background = "";
	edt_doc.body.scroll= "auto";
	if(Browser.ie)
	{
		edt_doc.body.onclick = edt_GetPos;
		edt_doc.body.onselect = edt_GetPos;
		edt_doc.body.onkeyup = edt_GetPos;
	}

	if(!Browser.ie)
	{
		edt_win.addEventListener('keydown', function(evt){ctlkey(evt);}, true);
	}
	else
	{
		edt_doc.body.attachEvent("onkeydown", ctlkey);
	}
	initBookMark();
}

function edt_GetPos()
{
	edt_win.pos = edt_doc.selection.createRange();
}

function edt_textMod()
{
	if(edt_mode)return;
	edt_mode = 1;
	var codemode = edt_getcodemode();
	if(codemode==1)
	edt_txtobj.value = edt_doc.body.innerHTML;
	else
	edt_txtobj.value = edt_htm2code(edt_doc.body.innerHTML);
	edt_htmobj.style.display='none';
	edt_txtobj.style.display='';
}

function edt_checkContent()
{
	var codemode = edt_getcodemode();
	if(!edt_mode) //htmledit
	{
		if(codemode==2)
		{
			edt_txtobj.value = edt_htm2code(edt_doc.body.innerHTML);
		}
		else
		{
			if(codemode!=1)
			edt_txtobj.value = edt_htm2txt(edt_doc.body.innerHTML);
			else
			edt_txtobj.value = edt_doc.body.innerHTML;
		}
	}
}

function edt_getcodemode()
{
	var obj=$id('LeadBBSFm');
	var codemode = 2;
	if(obj.Form_HTMLFlag)
	{
		codemode=(isUndef(obj.Form_HTMLFlag[0])?0:1);
	
		if(!codemode)
		{
			codemode=(obj.Form_HTMLFlag.checked?2:0)
		}
		else
		{
			if(obj.Form_HTMLFlag[0].checked)codemode=0;
			if(obj.Form_HTMLFlag[1].checked)codemode=1;
			if(obj.Form_HTMLFlag[2].checked)codemode=2;
		}
	}
	return codemode;
}
function edt_setmode(mode)
{
	if(edt_mode==mode)return;
	var codemode = edt_getcodemode();
	if(mode)
	{
		if(codemode==1)
		{
			//if(edt_initdone)alert("HTML\u7f16\u7801\u65b9\u5f0f\u4e0b\uff0c\u65e0\u6cd5\u9009\u62e9\u7eaf\u6587\u672c\u6a21\u5f0f\u3002");
			//return;
		}
		edt_textMod();
		$id('LEADEDT_EDIT').style.display = "none";
		$id('LEADEDT_TXT').style.display = "block";
		edt_txtobj.focus();
	}
	else
	{
		if(codemode==0)
		{
			if(edt_initdone)alert("\u7eaf\u6587\u672c\u7f16\u7801\u65b9\u5f0f\u4e0b\uff0c\u65e0\u6cd5\u9009\u62e9\u7eaf\u9ad8\u7ea7\u7f16\u8f91\u6a21\u5f0f\u3002");
			return;
		}
		edt_htmlMode();
		$id('LEADEDT_TXT').style.display = "none";
		$id('LEADEDT_EDIT').style.display = "block";
		edt_win.focus();
		edt_win.focus();

		$(edt_doc).bind("click",function(evt)
		{
			$(LD.mnu_cureWin).hide();
			$("#editor_selcolor").hide();
			if(LD.mnu_curele)$(LD.mnu_curele.info).hide();
		});
	}
}

function edt_url_filter(str)
{
	var tmp = str;
	tmp = tmp.replace(/(javascript|jscript|js|about|file|vbscript|vbs)(:)/gim,"$1%3a");
	tmp = tmp.replace(/(value)/gim,"%76alue");
	tmp = tmp.replace(/(document)(.)(cookie)/gim,"$1%2e$3");
	tmp = tmp.replace(/(')/g,"%27");
	tmp = tmp.replace(/(")/g,"%22");
	return(tmp);
}

function edt_PrintTrueText(str)
{
	if(str!="")
	{
		str = str.replace(/\n\ /gim,"<br>&nbsp;");
		str = str.replace(/\[p\]\ /gim,"[p]&nbsp;");
		str = str.replace(/\n/gim,"<br>");
		str = str.replace(/\ \ \ /gim," &nbsp; ");
		str = str.replace(/\ \ /gim," &nbsp;");
		str = str.replace(/\t/gim," &nbsp; &nbsp; &nbsp;");
		str = str.replace(/\ \[\/(td)\]/gim,"&nbsp;[/$1]");
		if(str.substr(0,1) == " ")str = "&nbsp;" + str.substr(1);
		return str;
	}
	else
	{return "";}
}

function htmlencode(str)
{
	//var re = /(<)/gim;
	//var rv = str.replace(re,"&lt;");
	//re = /(>)/gim;
	//rv = rv.replace(re,"&gt;");
	//re = /(\")/gim;
	//rv = rv.replace(re,"&quot;");
	//return(rv);
	return(str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\x22/g, '&quot;').replace(/\x27/g, '&#39;'));
}

function edt_bbscode(str)
{
	str = edt_PrintTrueText(htmlencode(str));
	str = str.replace(/\n/g, "");

	str = str.replace(/\[code\](.+?)\[\/code\]/gim,function($0,$1){var s = $1;s=s.replace(/\[/g,'&#91;');return("[CODE]" + s + "[/CODE]");});

	str = str.replace(/\[em([0-9]{1,4})\]/gi,"<img src=\"../images/UBBicon/em$1.GIF\" emotid=\"$1\">");

	str = str.replace(/\[(\/?(u|b|i|sup|sub|tr|td|strike|ul|ol|pre|p|li))\]/gim,"<$1>");
	str = str.replace(/\[td=([0-9]{1,2}),([0-9^\,]{1,2})[\,]?([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))?\]/gim,function($0,$1,$2,$3){var s=($3=="")?"":" bgColor="+$3;return("<td colspan=" + $1 + " rowspan=" + $2 + s + ">")});
	str = str.replace(/\[td=([0-9]{1,2}),([0-9^\,]{1,2})?\]/gim,function($0,$1,$2,$3){var s=($3=="")?"":" bgColor="+$3;return("<td colspan=" + $1 + " rowspan=" + $2 + s + ">")});

	str = str.replace(/\[hr\]/gim,"<hr size=1 color=#000000 style='BORDER-BOTTOM-STYLE: dotted; BORDER-LEFT-STYLE: dotted; BORDER-RIGHT-STYLE: dotted; BORDER-TOP-STYLE: dotted'>");
	str = str.replace(/\[(\/?)\*\]/gim,"<$1LI>");
	str = str.replace(/\[(\/?)PP\]/gim,"<$1P>");
	str = str.replace(/\[face=(.+?)\]/gim,function($0,$1){return("<font face=\"" + $1 + "\">");});
	str = str.replace(/\[FIELDSET=(.+?)\](.+?)\[\/FIELDSET\]/gim,"<FIELDSET><LEGEND>$1</LEGEND>$2</FIELDSET>");
	str = str.replace(/\[size=([0-9]{1,1})\]/gim,"<font size=\"$1\">");
	str = str.replace(/\[size=([a-z0-9\-\%]{1,4})\]/gim,"<font style=\"font-size:$1;line-height:2em;\">");
	str = str.replace(/\[color=([#0-9a-z\(\)\,\ ]{1,25})\]/gim,"<font style=\"color:$1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font style=\"BACKGROUND-COLOR: $1\">");
	str = str.replace(/\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]/gim,"<font style=\"BACKGROUND-COLOR: $1\" color=\"$2\">");
	str = str.replace(/\[\/(color|size|face|font|bgcolor)\]/gim,"</font>");
	
	str = str.replace(/\[LINE\-HEIGHT=(normal|[\.\%ptx0-9]{1,5})\]/gim,"<span style=\"line-height:$1\">");
	str = str.replace(/\[\/(line\-height)\]/gim,"</span>");
	
	str = str.replace(/\[email=(.+?)\](.*?)\[\/email\]/gi,function($0,$1,$2){if($2=="")$2=$1;return("<a href=\"mailto:" + edt_url_filter($1) + "\">" + $2 + "</a>")});
	str = str.replace(/\[email\](.+?)\[\/email\]/gi,function($0,$1,$2){return("<a href=\"mailto:" + edt_url_filter($1) + "\">" + $1 + "</a>")});
	
	str = str.replace(/\[align=(left|center|right|justify)\]/gim,"<span style=\"text-align:$1\">");
	str = str.replace(/\[\/align\]/gim,"</span>");
	str = str.replace(/\[imga?=?([0-9]{1,2})?,?(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)?,?([0-9\%]{1,5})?,?([0-9\%]{1,5})?\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga?\]/gi,function($0,$1,$2,$3,$4,$5,$6){
		var b = $1?" border=\""+$1+"\"":"";
		var w = $4?" width=\""+$4+"\"":"";
		var h = $3?" height=\""+$3+"\"":"";
		var a = $2?" align=\""+$2+"\"":"";
		return("<img" + h + " src=\"" + edt_url_filter($5+$6) + "\"" + w + a + b + " onmouseover=\"adjustW(this)\" onload=\"adjustW(this)\">")});

	str = str.replace(/\[url=(.+?)\](.*?)\[\/url\]/gi,function($0,$1,$2){if($2=="")$2=$1;return("<a href=" + edt_url_filter($1) + " target=_blank>" + $2 + "</a>")});
	str = str.replace(/\[url\](.+?)\[\/url\]/gi,function($0,$1){return("<a href=" + edt_url_filter($1) + " target=_blank>" + $1 + "</a>")});

	str = str.replace(/\[table\](.+?)\[\/table\]/gim,"<table class=anctb>$1</table>");
	str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),([0-9]{1,3}),([0-9\%\.\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " style=\"background-color:" + $6 + ";background-image:" + edt_url_filter($8) + "; border-color: " + $1 + ";\" border=" + $7 + ">" + $9+ "</table>")});
	//str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),([0-9]{1,3}),([0-9\%\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " style=\"background-color:" + $6 + ";background-image:" + edt_url_filter($8) + ";border-width: " + $7 + "px;border-color: " + $1 + ";\">" + $9+ "</table>")});
	str = edt_multscode(str);
	return str;
}

function edt_multscode(s)
{
	var str = s;
	var oldstr = "",tmp;
	tmp = str.toLowerCase();
	while(oldstr != str)
	{	oldstr = str;
		str = str.replace(/\[table\](.+?)\[\/table\]/gim,"<table class=anctb>$1</table>");
		str = str.replace(/\[table=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),([0-9]{1,3}),([0-9\%\|\"\&quot\;]{1,12}),(left|center|right),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([0-9]{1,3}),(.+?)\](.+?)\[\/table\]/gim,function($0,$1,$2,$3,$4,$5,$6,$7,$8,$9){return("<table borderColor=" + $1 + " cellSpacing=" + $2 + " cellPadding=" + $3 + " width=" + $4 + " align=" + $5 + " bgColor=" + $6 + " background=\"" + edt_url_filter($8) + "\" border=" + $7 + ">" + $9+ "</table>")});
		tmp = str.toLowerCase();
	}
	return(str);
}

function edt_KillHTMLLabel(str)
{
	var n,m=0,str2;
	n = str.indexOf("<");
	if(n>=0)m = str.indexOf(">",n);
	str2 = str;
	while(n >= 0 && n < m)
	{
		str2 = str2.substr(0,n) + str2.substr(m+1);
		n = str2.indexOf("<");
		if(n>=0)m = str2.indexOf(">",n);
	}
	return(str2);
}

function edt_multpub(s,r1,r2,br1,br2)
{
	var str = s;
	var oldstr = "",tmp;
	tmp = str.toLowerCase();
	
	var regbr1 = new RegExp(br1,"gi");
	var reg1 = new RegExp(r1,"gi");
	while(oldstr != str)
	{
		str = str.replace(/\n/gim,"");
		str = str.replace(regbr1,br2);
		oldstr = str;
		str = str.replace(reg1,r2);
		tmp = str.toLowerCase();
	}
	return(str);
}

function edt_fonttagGet(str)
{
	var arr = new Array("","");
	var size="",bgcolor="",color="",face="",align="",i="",u="",b="",lineheight="";
	tstr = " " + str;
	tstr=tstr.replace(/(\"|\=|\ |\'|\;)(size=|font-size\:[\s]*)[\"]?[\']?([a-z0-9\-\%]{1,15})[\']?[\"]?/gi,function($0,$1,$2,$3){size=$3;});
	tstr=tstr.replace(/(BACKGROUND\-COLOR\: |BACKGROUND\-COLOR\:)(rgb\([0-9\,\ ]{1,20}\)|[#a-z0-9]{1,12})/gi,function($0,$1,$2){bgcolor=$2;});
	tstr=tstr.replace(/(\"|\=|\ |\'|\;)(color=|COLOR\: |COLOR\:)[\"]?[\']?(rgb\([0-9\,\ ]{1,20}\)|[#a-z0-9]{1,12})[\']?[\"]?/gi,function($0,$1,$2,$3){color=$3;});
	tstr=tstr.replace(/(text-align\:[\s]*| align=)[\"]?[\']?(left|center|right)[\']?[\"]?/gi,function($0,$1,$2){align=$2;});
	tstr=tstr.replace(/(font\-family\:[\s]*|face=)[\"]?[\']?([^\[\<\"\'\;]+)[\']?[\"]?/gi,function($0,$1,$2){face=$2;});
	tstr=tstr.replace(/(font\-style\:)[\s]*[\"]?[\']?(italic|oblique)[\']?[\"]?/gi,function($0,$1,$2){i=$2;});
	tstr=tstr.replace(/(font\-weight\:[\s]*)[\"]?[\']?(bold|700)[\']?[\"]?/gi,function($0,$1,$2){b="B";});
	tstr=tstr.replace(/(text\-decoration\:[\s]*)[\"]?[\']?(underline|line\-through)[\']?[\"]?/gi,function($0,$1,$2){u=$2.toLowerCase();});
	tstr=tstr.replace(/(line\-height\:)[\s]*[\"]?[\']?(normal|[\.\%ptx0-9]{1,5})[\']?[\"]?/gi,function($0,$1,$2){lineheight=$2;});
	if(size!=""){arr[0]="[SIZE=" + size + "]" + arr[0];arr[1]=arr[1] + "[/SIZE]";}
	if(bgcolor!=""){arr[0]="[BGCOLOR=" + bgcolor + "]" + arr[0];arr[1]=arr[1] + "[/BGCOLOR]";}
	if(color!=""){arr[0]="[COLOR=" + color + "]" + arr[0];arr[1]=arr[1] + "[/COLOR]";}
	if(face!=""){arr[0]="[FACE=" + face + "]" + arr[0];arr[1]=arr[1] + "[/FACE]";}
	if(align!=""){arr[0]="[ALIGN=" + align + "]" + arr[0];arr[1]=arr[1] + "[/ALIGN]";}
	if(i!=""){arr[0]="[I]" + arr[0];arr[1]=arr[1] + "[/I]";}
	if(u=="underline"){arr[0]="[U]" + arr[0];arr[1]=arr[1] + "[/U]";}
	else{if(u=="line-through"){arr[0]="[STRIKE]" + arr[0];arr[1]=arr[1] + "[/STRIKE]";}}
	if(b!=""){arr[0]="[B]" + arr[0];arr[1]=arr[1] + "[/B]";}
	if(lineheight!=""){arr[0]="[LINE-HEIGHT=" + lineheight + "]" + arr[0];arr[1]=arr[1] + "[/LINE-HEIGHT]";}
	return (arr);
}

function edt_fonttag(str)
{
	var tstr,re;
	var tag = "div|font|span|i|u|b|strong|li|ul|p|blockquote";
	tag = tag.split("|");
	for(var i=0;i<tag.length;i++)
	{
		tstr="";
		while(tstr!=str)
		{
			str = str.replace(/\n/gim,"");
			re = new RegExp("</(" + tag[i] + ")>","gi");
			str = str.replace(re,"</$1>\n");
			tstr=str;
			var re = new RegExp("<(" + tag[i] + ") ([^>]*)>(.*?)\<\/" + tag[i] + "\>","gi");
			str = str.replace(re,function($0,$1,$2,$3,$4){var ar=edt_fonttagGet($2);if($1.toLowerCase()=="font" || $1.toLowerCase()=="span"){return(ar[0] + $3 + ar[1]);}else{return("<" + $1 + ">" + ar[0] + $3 + ar[1] + "</" + $1 + ">");}});
		}
	}
	return(str);
}

function edt_tabletagGet(str)
{
	var borderColor="",cellSpacing="",cellPadding="",width="";
	var align = "",bgColor="",background = "",border="";
	tstr = " " + str;
	tstr=tstr.replace(/( borderColor=|border\-color:[\s]*|border\-top\-color:[\s]*)[\"]?[\']?(rgb\([0-9\,\ ]{1,20}\)|[#a-z0-9]{1,12})[\']?[\"]?/gi,function($0,$1,$2){borderColor=$2;});
	tstr=tstr.replace(/(\"|\=|\ |\'|\;)(width=|width:[\s]*)[\"]?[\']?([%0\.-9px]*)[\']?[\"]?/gi,function($0,$1,$2,$3){width=$3;});
	tstr=tstr.replace(/ cellSpacing=[\"]?[\']?(\d+?)[\']?[\"]?/gi,function($0,$1){cellSpacing=$1;});
	tstr=tstr.replace(/ cellPadding=[\"]?[\']?(\d+?)[\']?[\"]?/gi,function($0,$1){cellPadding=$1;});
	tstr=tstr.replace(/(text-align\:[\s]*| align=)[\"]?[\']?(absmiddle|center|left|right|top|middle|bottom|absbottom|baseline|texttop)[\']?[\"]??/gi,function($0,$1,$2){align=$2;});
	tstr=tstr.replace(/(\"|\=|\ |\'|\;)(bgColor=|background\-color:)[\s]*[\"]?[\']?(rgb\([0-9\,\ ]{1,20}\)|[#a-z0-9]{1,12})[\']?[\"]?/gi,function($0,$1,$2,$3){bgColor=$3;});
	tstr=tstr.replace(/(\"|\=|\ |\'|\;)(background=|background\-image:)[\s]*[\"]?[\']?(.[^\;\[\ \"\'\>]*)[\']?[\"]?/gi,function($0,$1,$2,$3){background=$3;});
	tstr=tstr.replace(/( border=|border-width:|border\-top\-width:)[\s]*[\"]?[\']?(\d+?)[\']?[\"]?/gi,function($0,$1,$2){border=$2;});
	
	if(borderColor != "" || cellSpacing != "" || cellPadding!="" || width!="" || align!="" || bgColor!="" || background!="" || border!="")
	{
		if(borderColor=="")borderColor="transparent";
		if(cellSpacing=="")cellSpacing="0";
		if(cellPadding=="")cellPadding="0";
		if(width=="")width="100%";
		if(align=="")align="left";
		if(bgColor=="")bgColor="transparent";
		if(background=="")background="none";
		if(border=="")border="0";
	}
	else{return("");} 
	return("=" + borderColor + "," + cellSpacing + "," + cellPadding + "," + width + "," + align + "," + bgColor + "," + border + "," + background);
}

function edt_tabletag(str)
{
	var tstr="";
	while(tstr!=str)
	{
	str = str.replace(/\n/gim,"");
	str = str.replace(/\<\/(table)>/gi,"</$1>\n");
		tstr=str;
	str = str.replace(/\<table ([^>]*)>(.*?)\<\/table\>/gi,function($0,$1,$2){var ar=edt_tabletagGet($1);return("[TABLE" + ar + "]" + $2 + "[/TABLE]");});
	}
	return(str);
}

function edt_imgtagGet(str)
{
	var tstr=" " + str;
	var src="",align="",border="",width="",height="";
	tstr=tstr.replace(/( align=)[\"]?(top|bottom|middle|left|absmiddle|right)[\"]?/gi,function($0,$1,$2){align=$2;});
	tstr=tstr.replace(/( src=)[\"]?(\/|\.\.\/|http\:\/\/|https\:\/\/|ftp\:\/\/)(.[^\[\ \">]*)[\"]?/gi,function($0,$1,$2,$3){src=$2+$3;});
	tstr=tstr.replace(/ border=[\"]?(\d+?)[\"]?/gi,function($0,$1){border=$1;});
	tstr=tstr.replace(/ width=[\"]?([%0-9]*)[\"]?/gi,function($0,$1){width=$1;});
	tstr=tstr.replace(/ height=[\"]?([%0-9]*)[\"]?/gi,function($0,$1){height=$1;});
	if(src=="")return("");
	if(align == "" && border =="" && width =="" && height =="")return("[IMG]" + src + "[/IMG]");
	if(border=="")border="0";
	if(align=="")align="absmiddle";
	if(width !="" && height !="")
	{
		return("[IMG=" + border + "," + align + "," + height + "," + width + "]" + src + "[/IMG]");
	}
	else
	{
		return("[IMG=" + border + "," + align + "]" + src + "[/IMG]");
	}
}

function edt_imgtag(str)
{
	var tstr="";
	while(tstr!=str)
	{
	str = str.replace(/\n/gim,"");
	str = str.replace(/\<img /gi,"\n\<img ");
		tstr=str;
	str = str.replace(/\<img ([^>]*)>/gi,function($0,$1){return(edt_imgtagGet($1));});
	}
	return(str);
}


function edt_tdtagGet(str)
{
	var tstr=" " + str;
	var col="",row="",bg="";
	tstr=tstr.replace(/ (colspan|rowspan)=[\"]?[\']?([%0-9]*)[\"]?[\']?/gi,function($0,$1,$2){$1.toLowerCase()=="colspan"?col=$2:row=$2;});
	tstr=tstr.replace(/ bgColor=[\"]?[\']?(rgb\([0-9\,\ ]{1,20}\)|[#a-z0-9]{1,12})[\']?[\"]?/gi,function($0,$1){bg=$1;});
	if(col !="" || row !="" || bg!="")
	{
		if(col=="")col=1;
		if(row=="")row=1;
		if(bg!=="")bg="," + bg;
		return("=" + col + "," + row + bg);
	}
	else
	{
		return("");
	}
}

function edt_tdtag(str)
{
	var tstr="";
	while(tstr!=str)
	{
	str = str.replace(/\n/gim,"");
	str = str.replace(/\<td /gi,"\n\<td ");
	tstr=str;
	str = str.replace(/\<TD ([^>]*)>/gi,function($0,$1){var ar=edt_tdtagGet($1);return("[TD" + ar + "]");});
	}
	return(str);
}

function edt_clstag(str)
{
	str = str.replace(/\<(style)/gi,"\n<$1");
	str = str.replace(/\<style.*?>[\\\s\\\S]*?<\/style>/gi,"");
	str = str.replace(/\<script.*?>[\\\s\\\S]*?<\/script>/gi,"");
	str = str.replace(/\<\!\-\-[\\\s\\\S]*?-->/gi,"");
	str = str.replace(/\<object.*?>[\s\S]*?<\/object>/gi,"");
	str = str.replace(/\<select.*?>[\s\S]*?<\/select>/gi,"");
	str = str.replace(/\<noscript.*?>[\\\s\\\S]*?<\/noscript>/gi,"");
	str = str.replace(/\son[\w]{3,16}\s?=\s*([\'\"]).+?\1/gi,'');
	return(str);
}

function edt_htm2code(str)
{
	str = str.replace(/\n/gim,"");
	str = str.replace(/\r/gim,"");
	str = edt_clstag(str);
	
	str = str.replace(/\[code\](.+?)\[\/code\]/gim,function($0,$1){var s = $1;s=s.replace(/\[/g,'&#91;');return("[CODE]" + edt_codefilter(s) + "[/CODE]");});

	str = str.replace(/\<(IMG)\ /gi,"\n<$1 ");
	str = str.replace(/\<IMG[^>]+emotid=\"([0-9]{1,4})\"[^>]*\>/gi,"[EM$1]");
	
	str = edt_imgtag(str);

	str = str.replace(/\n/gim,"");
	str = str.replace(/\<\/(FIELDSET)>/gi,"</$1>\n");
	str = str.replace(/\<FIELDSET[^>]*\>\<LEGEND\>([^>]*)<\/LEGEND>(.*)?<\/FIELDSET>/gi,"[FIELDSET=$1]$2[/FIELDSET]");

	str = edt_tabletag(str);
	str = edt_fonttag(str);
	str = edt_tdtag(str);

	str = str.replace(/\n/gim,"");

	str = str.replace(/\<div (.[^\[\>]*)\>/gi,"<p $1>");
	str = str.replace(/\<div\>/gi,"<p>");
	str = str.replace(/\<\/div\>/gi,"</p>");

	str = str.replace(/\<(tr|td|sup|sub|ul|ol|i|u|b|STRIKE|li|hr|blockquote) (.[^\[\>]*)\>/gi,"[$1]");
	str = str.replace(/\<(tr|td|sup|sub|ul|ol|i|u|b|STRIKE|li|hr|blockquote)\>/gi,"[$1]");
	str = str.replace(/\<\/(tr|td|sup|sub|ul|ol|i|u|b|STRIKE|li|hr|blockquote)\>/gi,"[/$1]");

	str = str.replace(/\<li (.[^\[\>]*)\>/gi,"[LI]");
	str = str.replace(/\<li>/gi,"[LI]");
	str = str.replace(/\<\/LI>/gi,"[/LI]");

	str = str.replace(/\<(strong) (.[^\[\>]*)\>/gi,"[B]");
	str = str.replace(/\<(strong)>/gi,"[B]");
	str = str.replace(/\<\/(strong)>/gi,"[/B]");

	str = str.replace(/\<dir (.[^\[\>]*)\>/gi,"[UL]");
	str = str.replace(/\<dir>/gi,"[UL]");
	str = str.replace(/\<\/dir>/gi,"[/UL]");

	str = str.replace(/\<em (.[^\[\>]*)\>/gi,"[i]");
	str = str.replace(/\<em>/gi,"[i]");
	str = str.replace(/\<\/em>/gi,"[/i]");

	str = str.replace(/\<marquee (.[^\[\>]*)\>/gi,"[FLY]");
	str = str.replace(/\<marquee>/gi,"[FLY]");
	str = str.replace(/\<\/marquee>/gi,"[/FLY]");


	str = str.replace(/\<\/(a)>/gi,"</$1>\n");

	str = str.replace(/\<a [^>]*HREF=\"mailto:(.[^\[\ \">]*)\"[^>]*>(.*)?\<\/A\>/gi,"[EMAIL=$1]$2[/EMAIL]");
	str = str.replace(/\<a [^>]*HREF=\"(.[^[\ \"\>]*)\"[^>]*>(.*)?\<\/A\>/gi,"[URL=$1]$2[/URL]");
	str = str.replace(/\<a HREF=\"(.[^[\ \"\>]*)\">(.*)?\<\/A\>/gim,"[URL=$1]$2[/URL]");

	str = str.replace(/\<\/(color|size|face|font)\>/gi,"[/$1]");
	str = str.replace(/\n/gim,"");

	str = edt_htm2txt(str);
	return str;
}
function edt_codefilter(str)
{
	str = str.replace(/\n/gim, "");
	str = str.replace(/\>/gim,">\n");

	str = str.replace(/(.{1,1})\<p (.[^\[\>]*)\>/gi,"$1\n");
	str = str.replace(/\n/gim,"");
	str = str.replace(/(.{1,1})\<p>/gim, "$1\n");
	str = str.replace(/\<\/p>/gim, "");
	str = str.replace(/\<p (.[^\[\>]*)\>/gi,"\n");
	str = str.replace(/\<\/p>/gim,"\n");
	str = str.replace(/<br\s+?style=(["']?)clear: both;?(\1)[^\>]*>/ig, '');
	str = str.replace(/<br[^\>]*>/ig, "\n");
	str = str.replace(/\<br>\n/gim,"\n");
	str = str.replace(/\<br>/gim,"\n");

	str = edt_KillHTMLLabel(str);

	str = str.replace(/\n/gim,"<br>");
	return(str);
}

function edt_htm2txt(str)
{
	str = str.replace(/\n/gim, "");
	str = str.replace(/\>/gim,">\n");
	str = str.replace(/(.{1,1})\<p (.[^\[\>]*)\>/gi,"$1<p>");
	str = str.replace(/\n/gim,"");
	str = str.replace(/<br\s+?style=(["']?)clear: both;?(\1)[^\>]*>/ig, '');
	str = str.replace(/<br[^\>]*>/ig, "\n");
	str = str.replace(/\ \&nbsp; \&nbsp; \&nbsp;/gim,"\t");
	str = str.replace(/\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;/gim,"\t");
	str = str.replace(/\<br>\n/gim,"\n");
	str = str.replace(/\<br>/gim,"\n");
	str = str.replace(/\&nbsp;/gim," ");

	//str = str.replace(/\<p>[\s]*<\/p>/gim, "[P]  [/P]");
	str = str.replace(/(.{1,1})\<p>/gim, "$1[P]");
	str = str.replace(/\<p>/gim, "[P]");
	str = str.replace(/<\/p>/gim, "[/P]");

	str = str.replace(/\<p (.[^\[\>]*)\>/gi,"[P]");
	str = edt_KillHTMLLabel(str);
	//str = str.replace(/\&gt;/gim,">");
	//str = str.replace(/\&lt;/gim,"<");
	//str = str.replace(/\&quot;/gim,"\"");
	return(str.replace(/\&lt;/g, '\<').replace(/\&gt;/g, '\>').replace(/\&quot;/g, '\x22').replace(/\&#39;/g, '\x27').replace(/\&amp;/g, '\&'));
	//str = str.replace(/\&amp;/gim,"&"); //allow special character
	//return(str);
}

function edt_preview(hide)
{
	if(!hide)
	{
		var obj=$id('LeadBBSFm');
		if(obj.User){$id('Preview_UserName').innerHTML = htmlencode(obj.User.value);}
		else if(obj.Form_User){$id('Preview_UserName').innerHTML = htmlencode(obj.Form_User.value);}
		if(obj.Form_Title&&obj.Form_TitleStyle)$id("Preview_Title").innerHTML = DisplayAnnounceTitle(obj.Form_Title.value,obj.Form_TitleStyle.value);
		if(!edt_txtobj)return;
		var cm = edt_getcodemode();
		if(!edt_mode) //htmledit
		{
			if(cm==2)
			{
				edt_checkContent();
				$id('Preview_Content').innerHTML = edt_PrintTrueText(htmlencode(edt_txtobj.value));
				vnum = 0,urlname = 0,lrcnum = 0,nowobj=vnum+1;
				leadcode('Preview_Content');
			}
			else
			{
				if(cm==1)alert('HTML\u4ee3\u7801\u9884\u89c8\u4ec5\u652f\u6301\u663e\u793a\u7eaf\u6587\u672c\u72b6\u6001\u663e\u793a\uff0c\u9884\u89c8\u8bf7\u5bdf\u770b\u9ad8\u7ea7\u6a21\u5f0f\u3002');
				$id('Preview_Content').innerHTML = edt_PrintTrueText(htmlencode(edt_doc.body.innerHTML));
			}
		}
		else
		{
			if(cm==2)
			{
				//Preview_Content.innerHTML = convertcode(edt_PrintTrueText(htmlencode(edt_txtobj.value)));
				$id('Preview_Content').innerHTML = edt_PrintTrueText(htmlencode(edt_txtobj.value));
				vnum = 0,urlname = 0,lrcnum = 0,nowobj=vnum+1;
				leadcode('Preview_Content');
			}
			else
			{
				if(cm==1)alert('HTML\u4ee3\u7801\u9884\u89c8\u4ec5\u652f\u6301\u663e\u793a\u7eaf\u6587\u672c\u72b6\u6001\u663e\u793a\uff0c\u9884\u89c8\u8bf7\u5bdf\u770b\u9ad8\u7ea7\u6a21\u5f0f\u3002');
				$id('Preview_Content').innerHTML = edt_PrintTrueText(htmlencode(edt_txtobj.value));
			}
		}
		$id('Preview').style.display = "";
	}
	else
	{
		$id('Preview').style.display = "none";
	}
	$("#Preview").ScrollTo(500)
}

function DisplayAnnounceTitle(str,style)
{
	if(str.substring(0,3).toLowerCase() == "re:" || str=="")return("");
	switch(style)
	{
		case "1": return(str+"<br><br>");
		case "2": return("<font color=red class=redfont>" + htmlencode(str) + "</font><br><br>");
		case "3": return("<font color=green class=greenfont>" + htmlencode(str) + "</font><br><br>");
		case "4": return("<font color=blue class=bluefont>" + htmlencode(str) + "</font><br><br>");
		default: return(htmlencode(str)+"<br><br>");
	}
}

function trim(str)
{
	return((str + '').replace(/(\s+)$/g, '').replace(/^\s+/g, ''));
}
function edt_link()
{
	if(!edt_mode)
	{
		if(!Browser.ie)
		{
			var url = trim(prompt('\u8bf7\u8f93\u5165\u94fe\u63a5\u5730\u5740', 'http://') + '');
			if(url!="undefined" && url!="null" && url!="http://")
			addcontent(2,"<a href=\"" + url + "\">" + url + "</a>");
		}
		else
		{
			edt_win.focus();
			edt_doc.execCommand('CreateLink');
		}
	}
	else
	{
		addcontent(0,'URL','/URL');
	}
}

function edt_getdoclen()
{
	return (edt_mode ? $id('Form_Content').value.length : edt_doc.body.innerHTML.length);
}


function storeCaret (textEl)
{
	if (textEl.createTextRange)
	{
	if(document.selection)
	textEl.caretPos = document.selection.createRange().duplicate(); 
	}
}

function ctlkey(event)
{
	if(event.ctrlKey && event.keyCode==13){submitonce($id('LeadBBSFm'));if(ValidationPassed)$id('LeadBBSFm').submit();return(false);}
	if(event.altKey && event.keyCode==83){submitonce($id('LeadBBSFm'));if(ValidationPassed)$id('LeadBBSFm').submit();return(false);}
	return(true);
}

var editor_oldview=null,editor_oldobj=null,editor_sAction="",editor_viewn=0;

function editor_view(obj,menu,file,js)
{
	var editdir = "";
	if (typeof editFile_dir != "undefined")editdir = editFile_dir;
	editor_saveRange();
	LD.clearOldLayer();
	var menuobj=$id(menu);
	if(obj.id==""){obj.id="editor_view"+editor_viewn;editor_viewn++;}
	if((editor_sAction!="bgcolor"&&editor_sAction!="bordercolor")||(menu!="editor_selcolor"))
	{
		if(menu!="editor_selcolor")editor_sAction = "";
		if((obj!=editor_oldobj || (editor_oldview!=null && editor_oldview!=menuobj)) && editor_oldview!=null)editor_oldview.style.display='none';
		if($id('editor_selcolor').style.display != "none")$id('editor_selcolor').style.display = "none";
		editor_oldview = menuobj;
		editor_oldobj = obj;
	}
	if(file && menuobj.innerHTML=="loading...")
	{
		getAJAX(editdir+"Edit/" + file,"",menu,0,"$import(\"" + editdir.replace(/\\/,"\\") + "Edit/" + js + "\",\"js\");");
	}
	if(file=="" && js)
	{$import(editdir+"Edit/" + js,"js");}

	if(menuobj.style.display == 'block' &&editor_sAction!="bgcolor"&&editor_sAction!="bordercolor")
	{
		menuobj.style.display = 'none';
		if($id('editor_selcolor').style.display != "none")$id('editor_selcolor').style.display = "none";
		return;
	}
	if(LD.checkfixed(obj)==1)
	$(menuobj).css("position","fixed");
	else
	$(menuobj).css("position","absolute");
	var x = LD.getX(obj,"abs");
	var y = LD.getY(obj,"abs")-1;
	var distHeight = obj.clientHeight;
	if(!distHeight)distHeight+=obj.offsetHeight;
	y += distHeight;
	menuobj.style.top = y + 'px';
	menuobj.style.left = x + 'px';
	menuobj.style.display = 'block';
	relocationxy(obj.id,menuobj.id,1);
}

function symbol_inst(obj){
	if (obj.innerHTML=="&nbsp;") return;
	addcontent(1,obj.innerHTML);
}

function edit_getStorage()
{
	if((typeof localStorage)=="undefined")return;
	if (localStorage) {
	var cur=localStorage.preformcontent;
	var sure = 0;
	edt_checkContent();
	if(cur&&$.trim($("#Form_Content").val())!="")
	{
		if(cur!=$("#Form_Content").val())
		{
			if(confirm("当前编辑内容将被保存内容替换，确认继续?")) 
			{
				sure=1;
			}
		}
		else
		{
			return;
		}
	}
	else{
		sure=1;
	}
	if(sure==1)
	{
	  if (cur) {
	   var codemode = edt_getcodemode();
	  	$("#Form_Content").val(cur);
	  	if(!isUndef(edt_doc))
	  	{
	  		$(edt_doc.body).empty();
	  		if(codemode==1)
			$(edt_doc.body).html(edt_txtobj.value);
			else
			$(edt_doc.body).html(edt_bbscode(edt_txtobj.value));
	  	}
	  	if(localStorage.savetime)
	  	{
	  		var d = new Date(localStorage.savetime);
			$("#savetime").html("(备份于 "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds()+")");
		}
	  }
	}}
}

function edit_autosave()
{	
	if((typeof localStorage)=="undefined")return;
	if($id("Form_Content"))
	  	if (localStorage)
	  	{
	  		edt_checkContent();
			if($.trim(edt_txtobj.value)!=""&&edt_txtobj.value!=localStorage.formcontent)
			{localStorage.formcontent = edt_txtobj.value;
				var d = new Date();
				localStorage.savetime=(d);
				$("#now_storage").show();
				$("#savetime").html("(备份于 "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds()+")");}
			

		}
}
$(document).ready(function () {
	if((typeof localStorage)=="undefined")return;
	setInterval(edit_autosave, 3000); 
	if (localStorage)
	{
		if(localStorage.savetime)
		{
			localStorage.presavetime = localStorage.savetime;
			var d = new Date(localStorage.presavetime);
			$("#get_storage").show();
			$("#presavetime").html("(备份于 "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds()+")");
		}
		if(localStorage.formcontent)
		{
			localStorage.preformcontent = localStorage.formcontent;
		}
		else
		{
			$("#get_storage").hide();
		}
	}
});
