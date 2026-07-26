<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../../User/inc/UserTopic.asp"-->
<!--#include file="Chat_Fun.asp"-->
<!--#include file="../../inc/Limit_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Const C_LMT_MaxChannel = 4 '最多频道

Main()

Sub Main

	Chat_EnablePageRequest = 0
	initDatabase()
	
	dim appflag : appflag = request("appflag")
	if appflag <> "1" then
		BBS_SiteHead DEF_SiteNameString & " - 聊天",0,"<span class=""navigate_string_step"">聊天</span>"
	else
		%>
		<html><head>
		<link rel="stylesheet" id="css" type="text/css" href="<%=DEF_BBS_homeUrl%>inc/style0.css" title="cssfile" />
		
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.js" type="text/javascript"></script>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/common.js" type="text/javascript"></script>
		</head><body>
		<div>
		<%
	end if
	UpdateOnlineUserAtInfo GBL_board_ID,"聊天"
	
	if appflag <> "1" then UserTopicTopInfo("plug")
	
	Dim Chat_Flag
	Chat_Flag = 0
	If GBL_CHK_Flag = 1 Then
		GBL_CHK_TempStr = ""
		CheckUserAnnounceLimit()
		If GBL_CHK_TempStr <> "" Then
			GBL_CHK_Flag = 0
			Response.Write "<div class=""alert"">你的用户属于禁言或屏蔽，或未经过认证．</div>"
		Else
			CheckisBoardMaster()
			If GBL_BoardMasterFlag >= 2 or GBL_CHK_Points >= 0 Then
				Chat_SessionCreate(GBL_CHK_User)
				Chat_ChatRoom()
				Chat_Flag = 1
			Else
				GBL_CHK_Flag = 0
				Response.Write "<div class=""alert"">暂时限定只有" & DEF_PointsName(8) & "或" & DEF_PointsName(5) & "或0以上" & DEF_PointsName(0) & "的成员才能访问．</div>"
			End If
		End If
	Else
		If Request("submitflag")="" Then
			DisplayLoginForm("请先登录")
		Else
			DisplayLoginForm(GBL_CHK_TempStr)
		End If
	End If
	if appflag <> "1" then UserTopicBottomInfo
	closeDataBase()
	If Chat_Flag = 1 Then Chat_initMessage
	If appflag <> "1" then
		SiteBottom()
	else
	%>
		<script type="text/javascript">
	<!--
		new LayerMenu('layer_item','layer_iteminfo');
		new LayerMenu('layer_item2','layer_iteminfo2');
		layer_initselect();
		
		var alls = document.getElementsByTagName('form'); 
		for(var i=0; i<alls.length; i++)
		{
			submit_disable(alls[i],1);
		}
		if (typeof initLightbox == 'function')initLightbox();
	-->
	</script>
	</div>
	</body></html>
	<%
	end if

End Sub



Sub Chat_initMessage

	Dim Index,World_Index,Temp,n
	World_Index = Application(DEF_MasterCookies & "_Chat_World_Index")
	Index = World_Index + 2
	If Index <> World_Index and Index <> -1 Then
		Temp = Application(DEF_MasterCookies & "_Chat_World")
		If Not isArray(Temp) Then Exit Sub   ' cold cache: no world-chat backlog to render yet
		Response.Write "<script>"
		If Index > World_Index Then
			For n = Index to Chat_MaxCache-1
				If Temp(n) <> "" Then Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
			For n = 0 to World_Index
				If Temp(n) <> "" Then Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
		Else
			For n = Index + 1 to World_Index
				If Temp(n) <> "" Then Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
		End If%>
		tryCls($id("c_out_1"));
		goDown($id("c_out_1_Table"));
		</script><%
	End If
	Session(DEF_MasterCookies & "_Chat_World_Index") = cCur(Application(DEF_MasterCookies & "_Chat_World_Index"))

End Sub

Sub c_ViewOnlineUser

	Response.Write "<span style=""color:#787878"" onclick=""alert(c_onlinelist.innerHTML);"">在线人员，点击选择私聊对象</span></b><table id=""c_onlinelist"">" & VbCrLf
	Dim Thing
	Dim tmp,tmp1
	tmp = len(DEF_MasterCookies & "_Chat_S_Data_")
	tmp1 = DEF_MasterCookies & "_Chat_S_Data_"
	For Each Thing in Application.Contents
		If Left(Thing,tmp) = tmp1 Then
			Response.Write "<tr id=""c_ol_usr_" & Mid(thing,tmp+1) & """><td><span class=""c_name2"" onclick=""c_sc(this.innerHTML)"" style=""cursor:pointer"">" & Mid(thing,tmp+1) & "</span></td></tr>"
		End If
	Next
	Response.Write "</table>"

End Sub

Function Chat_ChatRoom

	Const Chat_Width = 450
	%>
	<style type="text/css">
	.cnl_world{FONT-SIZE:9pt;color:#000000;}
	.cnl_alert{FONT-SIZE:9pt;color:red;}
	.cnl_bbs{FONT-SIZE:9pt;color:#008800;}
	.cnl_person{FONT-SIZE:9pt;color:#8B008B;}
	.cnl_isend{FONT-SIZE:9pt;color:blue;}
	.cnl_useron{FONT-SIZE:9pt;color:#CF6A08;}
	.cnl_useroff{FONT-SIZE:9pt;color:#666666;}
	.c_name{FONT-SIZE:9pt;font-family: Tahoma, Verdana;font-weight: bold;}
	.c_name2{FONT-SIZE:9pt;font-family: Tahoma, Verdana;}
	.c_window{BACKGROUND-COLOR:#b8b8b3;}
	.c_scrollbar{
	scrollbar-3dlight-color:#170708;
	scrollbar-arrow-color:#000000; 
	scrollbar-base-color:#170708; 
	scrollbar-darkshadow-color:#ffffff; 
	scrollbar-face-color:#EEEAEB; 
	scrollbar-highlight-color:#FBFDFC; 
	scrollbar-shadow-color:#170708;
	background-color:white;
	height:100%;
	overflow-y:auto;
	overflow-x:hidden;
	height:377px;
	width:100%;
	word-break:break-all;
	display:block;
	}
	.c_button{
	padding-top:2px;
	padding-left:2px;
	background-color:#989898;
	border:0px solid #FFFFFF;
	cursor:pointer;
	z-index:20;
	color:#E9F2F5;
	font-size:9pt;
	}
	.c_content{padding-top:5px;padding-bottom:5px;padding-left:8px;padding-right:8px;line-height:1.5;}
	.c_msg{padding-top:3px;padding-bottom:2px;}
	</style>
<script type="text/javascript">
function c_viewbutton(n)
{
	var maxn=4,i;
	for(i=1;i<n;i++)c_hidebutton(i);
	if($id("c_Winout_" + n).style.display=="none")
	{
		$id("c_Button" + n).style.backgroundColor="#C3C3C3";
		$id("c_Button" + n).style.color="#787878";
		$id("c_Winout_" + n).style.display="";
		goDown($id("c_out_" + n +"_Table"));
	}
	for(i=n+1;i<=maxn;i++)c_hidebutton(i);
	focusMes();
}
function c_hidebutton(n)
{
	$id("c_Button" + n).style.backgroundColor="#989898";
	$id("c_Button" + n).style.color="#E9F2F5";
	$id("c_Winout_" + n).style.display="none";
}

function c_removeuser(usr)
{
	//if($id("c_ol_usr_" + usr))$id("c_ol_usr_" + usr).removeNode(true);
	if($id("c_ol_usr_" + usr))$id("c_ol_usr_" + usr).parentNode.removeChild($id("c_ol_usr_" + usr));
}

function c_adduser(usr)
{
	if($id("c_ol_usr_" + usr))return;
	$id("c_onlinelist").insertRow(-1).id = "c_ol_usr_" + usr;
	$id("c_ol_usr_" + usr).insertCell(-1).id="c_ol_usr_cell_" + usr;;
	$id("c_ol_usr_cell_" + usr).innerHTML = "<td><span class=\"c_name2\" onclick=\"c_sc(this.innerHTML)\" style=\"cursor\:pointer\">" + usr + "</span></td>";
}

</script>
	
	<table border=0 cellpadding="0" cellspacing="0" height="380" width="<%=Chat_Width%>">
	<tr><td width="<%=Chat_Width-3%>" valign="top">
	
	<table border="0" cellpadding="0" cellspacing="0"><tr>
	<td><input TYPE="button" value="世界" class="c_button" style="color:#787878;background-color:#C3C3C3;" onclick="c_viewbutton(1);" hidefocus="true" id="c_Button1"></td>
	<td><input TYPE="button" value="私聊" class="c_button" style="" onclick="c_viewbutton(2);" hidefocus="true" id="c_Button2"></td>
	<td><input TYPE="button" value="论坛" class="c_button" style="" onclick="c_viewbutton(3);" hidefocus="true" id="c_Button3"></td>
	<td><input TYPE="button" value="在线" class="c_button" style="" onclick="c_viewbutton(4);" hidefocus="true" id="c_Button4"></td>
	</tr></table>
	<span id="uptext" name="uptext"> </span>
	<table border="0" cellpadding="1" cellspacing="0" height="377" width="<%=Chat_Width%>" class="c_window" id="c_Winout_1">
	<tr><td>
		<div class="c_scrollbar" id="c_out_1_Table">
			<div class="c_content" id="c_out_1">
				<br /><span style="color:#787878">此窗口显示最新聊天或相关信息.</span><br /><br />
			</div>
		</div>
	</td></tr>
	</table>
	<%Dim n
	For N = 2 to C_LMT_MaxChannel%>
	<table border="0" cellpadding="1" cellspacing="0" height=177 width="<%=Chat_Width%>" class="c_window" id="c_Winout_<%=n%>" style="display:none;">
	<tr><td>
		
		<div class="c_scrollbar" id="c_out_<%=n%>_Table">
			<div class="c_content" id="c_out_<%=n%>">
				<%If N = 4 Then c_ViewOnlineUser%>
			</div>
		</div>
	</td></tr>
	</table><%Next%>
	
	
	</td></tr></table>

	<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<form method="POST" action="Send.asp" id="mesForm" name="mesForm" onsubmit="messageSubmit();return false;">
	<tr>
		<td>
		<table cellspacing="0" cellpadding="0" border="0" style="margin:6px 0px 3px;">
		<tr><td style="padding-right:6px;">
			<input TYPE="hidden" name="inputCommand" id="inputCommand" value="">
			<input TYPE="hidden" name="ToUser" id="ToUser" value="">
			<select name="SelChannel" id="SelChannel" style="width:80" onchange="c_changeChannel(this);">
			<option value="99">私聊…</option>
			<option value="98">密:未选择</option>
			<option value="3">团队成员</option>
			<option value="2"><%=DEF_PointsName(9)%></option>
			<option value="1" selected>世界</option>
			</select>
		</td><td style="padding-right:6px;">
			<input name="input" type="text" id="input" maxlength="<%=Chat_MaxInput%>" class="fminpt input_3" size="40">
		</td><td style="padding-right:6px;">
			<input TYPE="button" value="发送" onclick="messageSubmit();" class="fmbtn btn_2">
		</td>
		<td>
			<span style="cursor:pointer" id="c_moreclick" onclick="c_viewmorefun(this);">[隐藏功能]</span>
		</td>
		</tr></table>
	</td>
	</tr>
	</form>
	<tr><td height="3"><td></tr>
	<tr><td><input TYPE="hidden" name="c_myname" id="c_myname" value="<%=htmlencode(GBL_CHK_User)%>"><div id="c_morefun">
	<table border="0" cellspacing="0" cellpadding="0"><tr><td>
		<table border="0" cellspacing="0" cellpadding="0"><tr>
		<td><span style="cursor:pointer" onclick="IconPage();"><img src="../../images/UBBicon/em15.GIF" style="cursor:pointer" align="middle" border="0" title="显示表情"></span></td>
		<td>&nbsp;<span style="cursor:pointer" onclick="window.open('help/action.html','','width=600,height=450,scrollbars=yes,status=yes');">聊天动作</a></td>
		<td>&nbsp;<%
		If Chat_DEF_ColorSpend > 0 Then
			Response.Write "花费" & Chat_DEF_ColorSpend & DEF_PointsName(0)
		Else
			Response.Write "免费"
		End If%>增色</td><td><select size="1" name="c_Color" onchange="addcontent('[color=' + this.value + ']','[/color]');" <%If GBL_CHK_Points < Chat_DEF_ColorSpend Then Response.Write " disabled=""true"""%>>
				<option value="">--</option>
				<script type="text/javascript">
				var Color_n,Color_l,Color_str = "f0f8ff faebd7 00ffff 7fffd4 f0ffff f5f5dc ffe4c4 ffebcd 0000ff 8a2be2 a52a2a deb887 5f9ea0 7fff00 d2691e ff7f50 000000 1e90ff 696969 6495ed fff8dc dc143c 00ffff 00008b 008b8b b8860b a9a9a9 006400 bdb76b 8b008b 556b2f ff8c00 9932cc 8b0000 e9967a 8fbc8f 483d8b 2f4f4f 00ced1 9400d3 ff1493 00bfff b22222 fffaf0 228b22 ff00ff dcdcdc f8f8ff ffd700 daa520 808080 008000 adff2f f0fff0 ff69b4 cd5c5c 4b0082 fffff0 f0e68c e6e6fa fff0f5 7cfc00 fffacd add8e6 f08080 e0ffff fafad2 90ee90 d3d3d3 ffb6c1 ffa07a 20b2aa 87cefa 778899 b0c4de ffffe0 00ff00 32cd32 faf0e6 ff00ff 800000 66cdaa 0000cd ba55d3 9370db 3cb371 7b68ee 00fa9a 48d1cc c71585 191970 f5fffa ffe4e1 ffe4b5 ffdead 000080 fdf5e6 808000 6b8e23 ffa500 ff4500 da70d6 eee8aa 98fb98 afeeee db7093 ffefd5 ffdab9 cd853f ffc0cb dda0dd b0e0e6 800080 ff0000 bc8f8f 4169e1 8b4513 fa8072 f4a460 2e8b57 fff5ee a0522d c0c0c0 87ceeb 6a5acd 708090 fffafa 00ff7f 4682b4 d2b48c 008080 d8bfd8 ff6347 40e0d0 ee82ee f5deb3 ffffff f5f5f5 ffff00 9acd32";
				Color_str=Color_str.split(" ");
				Color_l=Color_str.length;
				for(Color_n=0;Color_n<Color_l;Color_n++)
				document.write("<option style='COLOR: #" + Color_str[Color_n] + "; BACKGROUND-COLOR: #" + Color_str[Color_n] + "' value='#" + Color_str[Color_n] + "'>#" + Color_str[Color_n] + "</option>\n");
				</script>
				</select></td>
		</td></tr></table>
	</td></tr>
	<tr><td><span id="IconAll"></span>
	</td></tr></table>
	
	</div>
	</td></tr>
	</table>
	<p style="text-align:left;"><span style="font:11px Arial;font-family:Tahoma;color:gray;">Powered by LeadChat 1.0</i></span></p>
	<audio src='javascript:;' controls autoplay='autoplay' id='plug_bg_audio' style='display:none;'></audio>
	<bgsound src='javascript:;' loop='1' autostart='true' id='plug_bg_bgsound' style='display:none;'>

	<span id=audiocontent></span>

<script type="text/javascript">

function c_newmsgsnd()
{
	try{
	$("#plug_bg_audio").attr("src","<%=DEF_BBS_HomeUrl%>images/notify.mp3");
	$("#plug_bg_audio")[0].play();}
	catch(e){
	$("#plug_bg_bgsound").attr("src","<%=DEF_BBS_HomeUrl%>images/notify.mp3");
	};
}
<%Dim pg,Temp
pg = 16%>

var iconnum = <%=DEF_UBBiconNumber%>;
var c_maxinput = <%=Chat_MaxInput%>;
var c_face_pg=<%=pg%>;

function IconPage()
{
	if($id("IconAll").innerHTML=="")
	{
	var n,m=iconnum+1,str,t;
	str = "";
	for(n=1;n<m;n++)
	{
		if(n<10){t="0"+n;}else{t=n;}
		str+="<div class=\"icon_min\" onclick=\"addcontent('[em" + t + "]','');\"><table><tr><td align=center><img src=\"../../images/UBBicon/em" + t + ".GIF\" style=\"max-width:32px;max-height:32px;cursor:pointer;\" align=\"absmiddle\"";
		str+="></td></tr></table></div>";
		if(n%c_face_pg==0)str+="";
	}
	str+="";
	$id("IconAll").innerHTML=str;
	}
	else
	{
		if($id("IconAll").style.display=="none")
		{$id("IconAll").style.display="";}
		else
		{$id("IconAll").style.display="none";}
	}
}


function getPos(obj)
{
	obj.focus();
	var s;
	if(document.createRange)
	s=document.createRange();
	else if(document.selection&&document.selection.createRange)
	s=document.selection.createRange();
	if(!(Browser.ie11||Browser.ie12))
	{s.setEndPoint("StartToStart",obj.createTextRange());
	return(s.text.length);
	}
	else return obj.value.length;
}

function addcontent(str1,str2)
{
	var obj = $id("input");
	var str=str1 + str2;
	if(obj.value.length + str.length > c_maxinput){alert("发送内容过长，操作失败!");return;}
	obj.focus();
	if ((document.selection)&&(document.selection.type== "Text"))
	{
		var range = document.selection.createRange();
		var ch_text = range.text;
		if(str2.toLowerCase() == "[/color]")ch_text = ch_text.replace(/\[color=([#0-9a-z]{1,12})\](.+?)\[\/color\]/gim,"$2");
		range.text = str1 + ch_text + str2;
	} 
	else
	{
		if(str2.toLowerCase() == "[/color]")
		{
			obj.value  = obj.value .replace(/\[color=([#0-9a-z]{1,12})\](.+?)\[\/color\]/gim,"$2");
			obj.value = str1 + obj.value + str2;
		}
		else
		if (obj.createTextRange)
		{
			if(obj.caretPos)
			{
				var caretPos = obj.caretPos;
				caretPos.text = str1 + caretPos.text + str2;
			}
			else
			{
				var f = getPos(obj);
				if(f >= 0)
				{
					if(f == 0)
					{obj.value = str + obj.value;}
					else
					{obj.value = obj.value.substring(0,f) + str + obj.value.substring(f,obj.value.length+1);}
				}
				else{obj.value+=str;}
			}
		}
		else{obj.value+=str;}
		obj.focus();
		focusMes();
	}
}

function c_viewmorefun(cl)
{
	if($id("c_morefun").style.display=="none")
	{$id('c_morefun').style.display="";cl.innerHTML="[隐藏功能]";}
	else
	{$id('c_morefun').style.display="none";cl.innerHTML="[更多功能]";}
	focusMes();
}
</script>
<script src="inc/morefun.js" type="text/javascript"></script>
<script type="text/javascript">
var c_WorldDelay=<%=Chat_WorldDelay*1000%>;
var c_GetDelay=<%=Chat_GetDelay*1000%>;
var c_User="<%=urlencode(GBL_CHK_User)%>";
var c_sendtime = 0,c_reset=0;
String.prototype.trim  = function(){return this.replace(/^\s+|\s+$/g,"");}

//for firefox 
//if(typeof HTMLElement!="undefined" && !HTMLElement.prototype.insertAdjacentElement || !Browser.is_ie)
//for firefox and Safari
if(!Browser.is_ie)
{
     HTMLElement.prototype.insertAdjacentElement = function(where,parsedNode)
     {
        switch (where)
        {
            case 'beforeBegin':
                this.parentNode.insertBefore(parsedNode,this)
                break;
            case 'afterBegin':
                this.insertBefore(parsedNode,this.firstChild);
                break;
            case 'beforeEnd':
                this.appendChild(parsedNode);
                break;
            case 'afterEnd':
                if (this.nextSibling) this.parentNode.insertBefore(parsedNode,this.nextSibling);
                    else this.parentNode.appendChild(parsedNode);
                break;
         }
     }

     HTMLElement.prototype.insertAdjacentHTML = function (where,htmlStr)
     {
         var r = this.ownerDocument.createRange();
         r.setStartBefore(this);
         var parsedHTML = r.createContextualFragment(htmlStr);
         this.insertAdjacentElement(where,parsedHTML)
     }

     HTMLElement.prototype.insertAdjacentText = function (where,txtStr)
     {
         var parsedText = document.createTextNode(txtStr)
         this.insertAdjacentElement(where,parsedText)
     }
}


function c_changeChannel(obj)
{
	var str = obj.value;
	switch(str)
	{
		case "99":
			c_InputUser();
			break;
		case "98":
			var usr=$id("SelChannel").options[1].innerHTML.substring(2,$id("SelChannel").options[1].innerHTML.length);
			if(usr!="未选择"){$id("ToUser").value=usr;}
			else{c_InputUser();}
			break;
	}
	focusMes();
}


function c_InputUser()
{
	var input=prompt('请输入私聊对象',"");
	if(input!=null){
		if(""==input){
			alert("请输入正确的用户名!");
			c_InputUser();
			return;
		}else{
			input = input.trim();
			if(input.length>20)input=input.substring(0,20);
			c_sc(input);
		}
	}else{
		$id("SelChannel").value="1";
		$id("ToUser").value="";
	}
}


//选择私聊对象
function c_sc(usr)
{
	$id("SelChannel").options[1].innerHTML="密:" + usr;
	$id("SelChannel").value="98";
	$id("ToUser").value=usr;
	if($id('layer_SelChannel'))$id('layer_SelChannel').innerHTML="密:" + usr;
	focusMes();
}
	
function messageSubmit()
{
	var delay;
	if($id("SelChannel").value=="98")
	{delay=c_WorldDelay/4;}
	else
	{delay=c_WorldDelay;}
	if(getInput().trim()!=""||getInputCmd()!="")
	{
		var nowtime = c_gettime();
		if(nowtime-c_sendtime<delay && nowtime>c_sendtime)
		{
			addMessage('2',"<span class=\"redfont\">请稍候再发送消息！</span>");
		}
		else
		{
			c_setcommand(getInput().trim());
			c_sendtime = nowtime;
			if(getInputCmd()!="")
			{
				SetSubValue();
				c_submit();
				setInput("");
			}else
			{
				SetSubValue();
				setInputCmd(getInput());
				c_submit();
				setInput("");
			}
			setInputCmd("");
		}
	}
	focusMes();
}

function c_submit()
{
	var par="SelChannel=" + escape($id('SelChannel').value) + "&inputCommand=" + escape($id('inputCommand').value) + "&ToUser=" + escape($id('ToUser').value);
	getAJAX("Send.asp",par,"eval(tmp);",1);
}

function c_setcommand(str)
{
	var usr,fstr
	if(str.indexOf(" ")>-1)
	{
		fstr = str.substring(0,str.indexOf(" "));
		usr = str.substring(str.indexOf(" ")+1,str.length);
	}
	else
	{
		fstr = str;
		usr = "";
	}
	c_setcommand_face(usr.toLowerCase(),fstr);
}

function c_setcommand_face(usr,fstr)
{
	var myname = "",i = 1,n;
	if($id("c_myname"))myname = $id("c_myname").value.toLowerCase();
	if(usr!="" || $id("SelChannel").value=="98")i=3;
	if(usr==myname)i=2;//对自己
	for(n=0;n<c_dil;n++)
	{
		if((" " + c_di[n][0] + " ").indexOf(" " + fstr + " ")>-1)
		{
			$id("inputCommand").value = c_di[n][i];
			if(i==3)
			{
				if(usr != "")
				{
					$id("ToUser").value = usr;
				}
				else
				{
					if($id("SelChannel").value!="98" && $id("ToUser").value == "")$id("ToUser").value=$id("ToUser").value.substring(3,$id("ToUser").value.length);
				}
			}
			return;
		}
	}
}

function c_gettime()
{
	var t = new Date();
	return(t.getHours()*3600000+t.getMinutes()*60000+t.getSeconds()*1000+t.getMilliseconds());
}
	
function SetSubValue()
{
	
}
	
function getInput()
{
	return $id('mesForm').input.value;
}

function getInputCmd(s)
{
	return $id('mesForm').inputCommand.value;
}
	
function setInput(s)
{
	$id('mesForm').input.value=s;
}
function setInputCmd(s)
{
	$id('mesForm').inputCommand.value=s;
}
	
function focusMes()
{
	if(Browser.is_ie)
	{
	var r = $id('mesForm').input.createTextRange();
	r.collapse(false);
	r.select();
	}
	$id('mesForm').input.focus();
}

function addMessage_2(pos,mes)
{
	if(pos!="")
	{
		var posObj=$id(pos);
		posObj.insertAdjacentHTML("beforeEnd","<div class=\"c_msg\">" + mes + "</div>");
		tryCls(posObj);
		goDown($id(pos+"_Table"));
	}
}
	
function addMessage(pos,mes)
{
	if(c_reset==1)return;
	var c,tp="";
	mes = mes.replace(/\n/g,"");
	mes = mes.replace(/\r/g,"");
	switch(pos)
	{
		case "1":
			tp = "c_out_1";
			c = "<span class=\"cnl_world\">【世界】";
			mes = mes + "</span>";
			mes = c + C_IO_UBB(mes);
			break;
		case "2":
			tp = "c_out_1";
			c = "<span class=\"cnl_alert\">【提示】";
			mes = mes + "</span>";
			mes = c + C_IO_UBB(mes);
			break;
		case "3":
			tp = "c_out_1";
			c = "<span class=\"cnl_bbs\">【论坛】";
			mes = mes + "</span>";
			mes = c + C_IO_UBB(mes);
			addMessage_2("c_out_3",mes)
			break;
		case "4":
			tp = "c_out_1";
			c = "<span class=\"cnl_alert\">【公告】";
			mes = c + C_IO_UBB(mes);
			break;
		case "5":
		case "6":
			tp = "c_out_1";
			if(pos=="5")
			c = "<span class=\"cnl_person\">【私聊】";
			else
			c = "<span class=\"cnl_isend\">【私聊】";
			mes = mes + "</span>";
			mes = c + C_IO_UBB(mes);
			addMessage_2("c_out_2",mes);
			if(pos=="5")c_newmsgsnd();
			break;
		case "7":
			tp = "c_out_1";
			c = "<span class=\"cnl_useron\">【会员】";
			c_adduser(mes);
			mes = c + "<span onclick=\"c_sc(this.innerHTML)\" style=\"cursor:pointer\" class=\"c_name\">" + mes + "</span>上线了!";
			mes = mes + "</span>";
			break;
		case "8":
			tp = "c_out_1";
			c = "<span class=\"cnl_useroff\">【会员】";
			c_removeuser(mes);
			mes = c + "<span class=\"c_name\">" + mes + "</span>离开了!";
			mes = mes + "</span>";
			break;
		case "9":
			tp = "c_out_1";
			c = "<span class=\"cnl_alert\">【提示】";
			switch(mes)
			{
				case "stop":
						mes = "此用户被重复登录停止动作，若要继续请<a href=\"#\" onclick=\"top.window.location.reload();\" >[刷新].</a>";
						window.clearTimeout(C_IOfun);
						break;
				case "guest":
						mes = "过久无动作或未登录而终止，要继续请<a href=\"#\" onclick=\"top.window.location.reload();\" >[刷新].</a>";
						window.clearTimeout(C_IOfun);
						break;
				case "reset":
						mes = "系统重启，若要继续请<a href=\"#\" onclick=\"top.window.location.reload();\" >[刷新].</a>";
						window.clearTimeout(C_IOfun);
						c_reset = 1;
						break;
			}
			mes = mes + "</span>";
			mes = c + C_IO_UBB(mes);
			break;
	}
	if(tp!="")
	{
		var posObj=$id(tp);
		posObj.insertAdjacentHTML("beforeEnd","<div class=\"c_msg\">" + mes + "</div>");
		tryCls(posObj);
		goDown($id(tp+"_Table"));
	}
}

function tryCls(posObj)
{
	//if(posObj.scrollHeight>3000)
	if(posObj.innerHTML.length>22000)
	{
		var now=posObj.innerHTML;
		now=now.substring(now.length/2,now.length);
		if(now.indexOf("</divs>") > 0)
			now=now.substring(now.indexOf("</divs>")+6,now.length);
		else
			now=now.substring(now.indexOf(">")+1,now.length);
		posObj.innerHTML = now;
	}
}
	
function goDown(posObj)
{
	posObj.scrollTop=6500;
}

var C_IOfun,C_Level=0,C_err=0,C_errtime=1,C_errstr;

function C_IO(ur,lb,id)
{
	C_Level += 1;
	delete HR ;
	var HR = getHttp();
	HR.onreadystatechange = function() {processAJAX(lb);};
	HR.open("POST", "Chat_IO.asp" , true);
	HR.setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8");
	HR.send("user=" + c_User);
	function processAJAX(lb)
	{
		if (HR.readyState == 4)
		{
			if (HR.status == 200)
			{
				if(HR.responseText=="busy")
				{
					addMessage("2","<b>注意: </b>请求过频，此窗口已暂停处理，若开启多窗口，请关闭其它窗口再<a href=\"#\" onclick=\"top.window.location.reload();\" >[刷新].</a><br />");
					window.clearTimeout(C_IOfun);
					return;
				}
				if(C_err==1)
				{
					addMessage("2","<b><span class=\"greenfont\">聊天室重新连接成功。</span></b><br />");
					C_err = 0;
					C_errtime = 1;
				}
				C_IO_processor(HR.responseText);
			}
			else
			{
				C_err = 1;
				C_errstr = HR.statusText;
			}
			delete HR ; 
			HR=null;
			if(Browser.is_ie)CollectGarbage;
		}
	}
	if(C_err==1)
	{
		addMessage("2","<b>错误: </b>[" + C_errstr + "]，" + ((C_errtime==1)?"已断开连接":"连接失败") + "，将在" + (C_errtime*10>60?parseInt(C_errtime*10/60)+"分":C_errtime*10+"秒") + "后尝试连接。<br />");
		window.clearTimeout(C_IOfun);
		C_Level -= 1;
		C_IOfun = window.setTimeout(C_IO,C_errtime*10*1000);
		C_errtime += 1;
		return;
	}
	window.clearTimeout(C_IOfun);
	if(C_Level<2)C_IOfun = window.setTimeout(C_IO,c_GetDelay);
	C_Level -= 1;
}

function C_IO_processor(str)
{
	var n,tmp1,tmp = str.split("\n"); 
	for(n=0;n<tmp.length;n++)
	{
		tmp1 = tmp[n].indexOf(" ");
		if(tmp1>-1)
		{
			c=tmp[n].substring(0,tmp1)
			tmp[n]=tmp[n].substring(tmp1+1,tmp[n].length)
			addMessage(c + "",tmp[n]);
		}
	}
}

function C_IO_UBB(str)
{
	str = str.replace(/\[(\/?(sup|sub))\]/gim,"<$1>");
	str = str.replace(/\[em([0-9]{1,4})\]/gi,"<img src=\"../../images/UBBicon/em$1.GIF\" align=\"absmiddle\">");//[em**]
	str = str.replace(/\[color=([#0-9a-z]{1,12})\](.+?)\[\/color\]/gim,"<font color=\"$1\">$2</font>");//[color]
	str = str.replace(/\[color=([#0-9a-z]{1,12})\]\[\/color\]/gim,"<font color=\"$1\">…</font>");//[color]
	str = str.replace(/\[bgColor=([#0-9a-z]{1,12}),([#0-9a-z]{1,12})\](.+?)\[\/bgColor\]/gim,"<font style=\"BACKGROUND-COLOR: $1\" color=\"$2\">$3</font>");//[bgcolor]
	str = str.replace(/( |\n|\r|\t|\v|\<br\>|\：|\:|　)(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<　]*)/gi,function($0,$1,$2,$3){var u=$2;if(u.substr(0,4).toLowerCase()=='www.')u='http://'+u;return($1+'<a href=\"' + C_IO_filter(u+$3) + '\" target=\"_blank\">' + u+$3 + '</a>');});//[url]
	return str;
}

function C_IO_filter(str)
{
	var tmp = str;
	tmp = tmp.replace(/(javascript|jscript|js|about|file|vbscript|vbs)(:)/gim,"$1%3a");
	tmp = tmp.replace(/(value)/gim,"%76alue");
	tmp = tmp.replace(/(document)(.)(cookie)/gim,"$1%2e$3");
	tmp = tmp.replace(/(')/g,"%27");
	tmp = tmp.replace(/(")/g,"%22");
	return(tmp);
}

C_IOfun = window.setTimeout(C_IO,c_GetDelay);
<%If Request.QueryString("c") = "2" Then Response.Write "c_viewbutton(2);" & VbCrLf%>

//window.onbeforeunload = function(){return("离开页面将清除当前聊天记录");}
</script>
    
<%End Function%>