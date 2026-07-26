var BrowserInfo = new Object() ;
BrowserInfo.MajorVer = navigator.appVersion.match(/MSIE (.)/)[1] ;
BrowserInfo.MinorVer = navigator.appVersion.match(/MSIE .\.(.)/)[1] ;
BrowserInfo.IsIE55OrMore = BrowserInfo.MajorVer >= 6 || ( BrowserInfo.MajorVer >= 5 && BrowserInfo.MinorVer >= 5 ) ;

var btnDatas = new Array();

var bInitialized = false;
function document.onreadystatechange()
{
	if (document.readyState!="complete") return;
	if (bInitialized) return;
	bInitialized = true;

	var i, s, curr;

	if (LeadBBSFm.ContentFlag.value=="0") { 
		LeadBBSFm.ContentEdit.value = objContent.value;
		LeadBBSFm.ContentLoad.value = objContent.value;
		LeadBBSFm.ContentFlag.value = "1";
	}

	LEADEDT.document.designMode="On";
	LEADEDT.document.open();
	LEADEDT.document.write(bodyTag+LeadBBSFm.ContentEdit.value)
	LEADEDT.document.close();
	setLinkedField() ;
	LEADEDT.document.body.onpaste = onPaste ;
	LEADEDT.focus();
}

function setLinkedField() {
	if (! objContent) return ;
	var oForm = objContent.form ;
	if (!oForm) return ;
	oForm.attachEvent("onsubmit", AttachSubmit) ;
	if (! oForm.submitEditor) oForm.submitEditor = new Array() ;
	oForm.submitEditor[oForm.submitEditor.length] = AttachSubmit ;
	if (! oForm.originalSubmit) {
		oForm.originalSubmit = oForm.submit ;
		oForm.submit = function() {
			if (this.submitEditor) {
				for (var i = 0 ; i < this.submitEditor.length ; i++) {
					this.submitEditor[i]() ;
				}
			}
			this.originalSubmit() ;
		}
	}
	oForm.attachEvent("onreset", AttachReset) ;
	if (! oForm.resetEditor) oForm.resetEditor = new Array() ;
	oForm.resetEditor[oForm.resetEditor.length] = AttachReset ;
	if (! oForm.originalReset) {
		oForm.originalReset = oForm.reset ;
		oForm.reset = function() {
			if (this.resetEditor) {
				for (var i = 0 ; i < this.resetEditor.length ; i++) {
					this.resetEditor[i]() ;
				}
			}
			this.originalReset() ;
		}
	}
}

function AttachSubmit() {
	if (!bEditMode) setMode('EDIT');

	LeadBBSFm.ContentEdit.value = getHTML();
	objContent.value = LeadBBSFm.ContentEdit.value;

	var oForm = objContent.form ;
	if (!oForm) return ;

	for (var i=1;i<document.getElementsByName(sContentName).length;i++) {
		document.getElementsByName(sContentName)[i].value = "";
	}
} 

function AttachReset() {
	if (!bEditMode) setMode('EDIT');
	if(bEditMode){
		LEADEDT.document.body.innerHTML = LeadBBSFm.ContentLoad.value;
	}else{
		LEADEDT.document.body.innerText = LeadBBSFm.ContentLoad.value;
	}
}

function onPaste() {
	if (config.AutoDetectPasteFromWord && BrowserInfo.IsIE55OrMore) {
		var sHTML = GetClipboardHTML() ;
		var re = /<\w[^>]* class="?MsoNormal"?/gi ;
		if ( re.test( sHTML ) )
		{
			if ( confirm( "你要粘贴的内容好象是从Word中拷出来的，是否要先清除Word格式再粘贴？" ) )
			{
				cleanAndPaste( sHTML ) ;
				return false ;
			}
		}
	}
	else
		return true ;
}

function GetClipboardHTML() {
	var oDiv = document.getElementById("divTemp")
	oDiv.innerHTML = "" ;

	var oTextRange = document.body.createTextRange() ;
	oTextRange.moveToElementText(oDiv) ;
	oTextRange.execCommand("Paste") ;
	
	var sData = oDiv.innerHTML ;
	oDiv.innerHTML = "" ;
	
	return sData ;
}

function cleanAndPaste( html ) {
	html = html.replace(/<\/?SPAN[^>]*>/gi, "" );
	html = html.replace(/<(\w[^>]*) class=([^ |>]*)([^>]*)/gi, "<$1$3") ;
	html = html.replace(/<(\w[^>]*) style="([^"]*)"([^>]*)/gi, "<$1$3") ;
	html = html.replace(/<(\w[^>]*) lang=([^ |>]*)([^>]*)/gi, "<$1$3") ;
	html = html.replace(/<\\?\?xml[^>]*>/gi, "") ;
	html = html.replace(/<\/?\w+:[^>]*>/gi, "") ;
	html = html.replace(/&nbsp;/, " " );
	var re = new RegExp("(<P)([^>]*>.*?)(<\/P>)","gi") ;	// Different because of a IE 5.0 error
	html = html.replace( re, "<span$2</span>" ) ;
	insertHTML( html ) ;
}

function insertHTML(html) {
	if (!validateMode()) return;
	if (LEADEDT.document.selection.type.toLowerCase() != "none")
		LEADEDT.document.selection.clear() ;
	LEADEDT.document.selection.createRange().pasteHTML(html) ; 
}

function getHTML() {
	if(bEditMode){
		return LEADEDT.document.body.innerHTML;
	}else{
		return LEADEDT.document.body.innerText;
	}
}

function PasteWord(){
	if (!validateMode()) return;
	LEADEDT.focus();
	if (BrowserInfo.IsIE55OrMore)
		cleanAndPaste( GetClipboardHTML() ) ;
	else if ( confirm( "此功能要求IE5.5版本以上，你当前的浏览器不支持，是否按常规粘贴进行？" ) )
		format("paste") ;
	LEADEDT.focus();
}

function PasteText(){
	if (!validateMode()) return;
	LEADEDT.focus();
	var sText = HTMLEncode( clipboardData.getData("Text") ) ;
	insertHTML(sText);
	LEADEDT.focus();
}

function validateMode() {
	if (bEditMode) return true;
	alert("需转换为编辑状态后再使用此功能！");
	LEADEDT.focus();
	return false;
}

function format(what,opt) {
	if (!validateMode()) return;
	LEADEDT.focus();
	if (opt=="RemoveFormat") {
		what=opt;
		opt=null;
	}
	if (opt==null) LEADEDT.document.execCommand(what);
	else LEADEDT.document.execCommand(what,"",opt);
	
	LEADEDT.focus();
}

function setMode(NewMode){
	document.onreadystatechange();
	if (NewMode!=sCurrMode){
		document.all["LEADEDT_CODE"].style.display = "none";
		document.all["LEADEDT_EDIT"].style.display = "none";
		document.all["LEADEDT_VIEW"].style.display = "none";
		document.all["LEADEDT_"+NewMode].style.display = "block";
		switch (NewMode){
		case "CODE":
			if (LEADEDT.document.designMode=="On") {
				LEADEDT.document.body.innerText=LEADEDT.document.body.innerHTML;
			}else {
				var temp=LEADEDT.document.body.innerHTML;
				LEADEDT.document.designMode="On";
				LEADEDT.document.open();
				LEADEDT.document.write(bodyTag);
				LEADEDT.document.body.innerText=temp;
				LEADEDT.document.close();
				temp=null;
			}
			bEditMode=false;
			break;
		case "EDIT":
			LEADEDT.document.body.disabled=false;
			if (LEADEDT.document.designMode=="On") {
				LEADEDT.document.body.innerHTML=LEADEDT.document.body.innerText;
			}else {
				var temp=LEADEDT.document.body.innerHTML;
				LEADEDT.document.designMode="On";
				LEADEDT.document.open();
				LEADEDT.document.write(bodyTag);
				LEADEDT.document.body.innerHTML=temp;
				LEADEDT.document.close();
				temp=null;
			}
			bEditMode=true;
			break;
		case "VIEW":
			var temp;
			if(bEditMode){
				temp = LEADEDT.document.body.innerHTML;
			}else{
				temp = LEADEDT.document.body.innerText;
			}
			LEADEDT.document.designMode="off";
			LEADEDT.document.open();
			LEADEDT.document.write(bodyTag+temp);
			LEADEDT.document.close();
			bEditMode=false;
			break;
		}
		sCurrMode=NewMode;
	}
	LEADEDT.focus();
}

function ShowDialog(url, width, height, optValidate) {
	if (optValidate) {
		if (!validateMode()) return;
	}
	LEADEDT.focus();
	var arr = showModalDialog(url, window, "dialogWidth:" + width + "px;dialogHeight:" + height + "px;help:no;scroll:no;status:no");
	LEADEDT.focus();
}

function HTMLEncode(text){
	text = text.replace(/&/g, "&amp;") ;
	text = text.replace(/"/g, "&quot;") ;
	text = text.replace(/</g, "&lt;") ;
	text = text.replace(/>/g, "&gt;") ;
	text = text.replace(/'/g, "&#146;") ;
	text = text.replace(/\ /g,"&nbsp;");
	text = text.replace(/\n/g,"<br>");
	text = text.replace(/\t/g,"&nbsp;&nbsp;&nbsp;&nbsp;");
	return text;
}

function insert(what) {
	if (!validateMode()) return;
	LEADEDT.focus();
	var sel = LEADEDT.document.selection.createRange();

	switch(what){
	case "nowdate":
		var d = new Date();
		insertHTML(d.toLocaleDateString());
		break;
	case "nowtime":
		var d = new Date();
		insertHTML(d.toLocaleTimeString());
		break;
	case "br":
		insertHTML("<br>")
		break;
	case "code":
		insertHTML('[CODE]'+HTMLEncode(sel.text)+'[/CODE]');
		break;
	case "quote":
		insertHTML('[QUOTE]'+HTMLEncode(sel.text)+'[/QUOTE]');
		break;
	case "fly":
		insertHTML('[FLY]'+HTMLEncode(sel.text)+'[/FLY]');
		break;
	default:
		insertHTML("[face=" + what + ']' + sel.text + "[/face]");
		break;
	}
	sel=null;
}

var bEditMode=true;
var sCurrMode = "EDIT";
var bodyTag = "<head><style type=\"text/css\">body,a,table,div,span,td,th,input,select{font-size:9pt;font-family:\"宋体,Verdana,Arial\";Color:#000000;}</style><meta http-equiv=Content-Type content=\"text/html; charset=gbk\"></head><body bgcolor=\"#FFFFFF\" MONOSPACE>" ;
var sContentName = "Form_Content" ;
var objContent = document.getElementsByName(sContentName)[0];

var config = new Object() ;
config.Version = "1.1.3" ;
config.ReleaseDate = "2003-12-11" ;
config.StyleName = "standard";
config.AutoDetectPasteFromWord = true;

function ds(a,b,c)
{
	document.write("<td width=23 align=center><img src=../images/null.gif width=23 height=2<br><span TITLE=\"" + a + "\" onclick=\"" + b + "\" class=GMI><IMG SRC=Edit/pic/" + c + ".gif width=22 height=22 class=ico onclick=\"this.style.backgroundColor='#AAAAAA';\" onmouseover=\"this.style.backgroundColor='#CCCCCC';\" onmouseout=\"this.style.backgroundColor='';\"></span></td>");
}
function dt()
{
	document.write("<td><img src=edit/pic/line2.gif width=10 height=16 align=absmiddle></td><td>");
}