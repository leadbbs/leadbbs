<%
' --- AxonASP fix (§5): these Consts must be declared BEFORE the includes that
' use them; AxonASP resolves a Const by source position, so a later Const reads
' as empty. Sch_AncTitle=empty made the title-search mode silently fall back to
' an author search, which is what the UI's default option submits. ---
Const Sch_AllContent = 0 '是否允许全部搜索,即同时搜索标题和内容，设为99表示采用hubbledotnet引擎ajax调用搜索，设为98采用组件方式调用hubbledotnet搜索
Const Sch_AncTitle = 1 '是否允许帖子标题搜索
Const Sch_AncContent = 1 '是否允许帖子内容搜索
Const Sch_LimitTime = 30 '限制搜索时间(单位秒)
%>
<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="../inc/Limit_Fun.asp"-->
<!--#include file="../User/inc/UserTopic.asp"-->
<!--#include file="inc/Search_fun.asp"-->
<!--#include file="inc/hubbleCom_fun.asp"-->
<%
Server.ScriptTimeOut = 120
DEF_BBS_HomeUrl = "../"
Dim LMT_WidthStr,GBL_NoneLimitFlag

sub LoginAccuessFul

	GBL_CHK_TempStr = ""
	
	if Sch_AllContent = 99 then
		search_foraspx()
		exit sub
	elseif Sch_AllContent = 98 then
		dim hubblesearchclass
		set hubblesearchclass = new hubblesearch_class
		set hubblesearchclass = nothing
		exit sub
	end if
	DisplaySearchForm()
	If Request("key") <> "" Then
		DisplayAnnouncesSplitPages()
	Else
		If GBL_ShowBottomSure = 0 Then GBL_SiteBottomString = ""
	End If

End sub



Class Proxy_Class

Public Sub GetBody(url)

	url = Left(url,5000)
	If url = "" Then Exit Sub
	Dim xmlHttp
	Set xmlHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
	xmlHttp.setTimeouts 5000,5000,5000,15000
	xmlHttp.setOption 2, 13056
	xmlHttp.open "GET", url, False, "", "" 
	
	on error resume next
	xmlHttp.send()
	If Err Then
		Exit Sub
	End If

	If xmlHttp.readystate = 4 then 
	'if xmlHttp.status=200 Then
		'Response.Write xmlHttp.ResponseText
		'Response.binaryWrite xmlhttp.Responsebody
		Response.Write BytesToBstr(xmlhttp.Responsebody)
	'end if 
	Else 
		Response.Write ""
	End If
	Set xmlHttp = Nothing

End Sub

private Function BytesToBstr(body) 

	'on error resume next
	dim objstream
	set objstream = Server.CreateObject("adodb.stream")
	with objstream
	.Type = 1
	.Mode = 3
	.Open
	.Write body 
	.Position = 0
	.Type = 2
	.Charset = "utf-8"
	
	'.Charset = "UTF-8"
	BytesToBstr = .ReadText
	.Close
	end with
	set objstream = nothing

End Function

End Class

Function search_foraspx

	GBL_CHK_TempStr = ""
	%>
	<style>
	#LabelSql{display:none;}
		.j_page span {
	font-weight:normal;color:gray;
	background-color:#f4f2c9; 
	margin:1px 0px 1px 3px;border: #f4f2c9 1px solid; padding: 1px 6px 0px 6px;overflow: hidden; line-height: 17px;height: 17px;_height /*5.5*/:19px; float: left;
	background-color:#ffffff;
	}
	
.j_page a,.j_page B {
	margin:0px;border: #f4f2c9 0px solid; padding: 0px;overflow: hidden; line-height: 17px;height: 17px;_height /*5.5*/:19px; float: left;
	background-color:#ffffff;color:black;
}
</style>
	<script type=text/javascript>
	function _doPost(cutomArg){
		submitonce($id('form1'),cutomArg);
		//document.forms['form1'].AspNetPager.value = cutomArg;
		//document.forms['form1'].submit();
	}
	var send="",page=0;
      	function submitonce(theform,page)
	{	
		send = "";
		if($id('TextBoxSearch').value=="")
		{
			alert("请输入要搜索的内容！\n");
			$id('TextBoxSearch').focus();
			return;
		}
		ValidationPassed = false;
		send="DropDownListSearchType=" + escape($id('DropDownListSearchType').value);
		if($id('DropDownListSort'))send=send+"&DropDownListSort=" + escape($id('DropDownListSort').value);
		if($id('TextBoxSearch'))send=send+"&TextBoxSearch=" + escape($id('TextBoxSearch').value);
		if($id('__VIEWSTATE'))send=send+"&__VIEWSTATE=" + escape($id('__VIEWSTATE').value);
		if(!isUndef(page))send=send+"&AspNetPager=" + escape(page);
		
		//if($id('__EVENTTARGET'))send=send+"&__EVENTTARGET=" + escape($id('__EVENTTARGET').value);
		//if($id('ButtonSearch'))send=send+"&ButtonSearch=" + escape($id('ButtonSearch').value);
		
		getAJAX("search.aspx",send,"searchPage",0,"if($id('LabelDuration')){$id('createtime').innerHTML=$id('LabelDuration').innerHTML;$id('LabelDuration').style.display='none';}if($id('AspNetPager')){$id('searchform').style.display='none';$id('searchheadpage').innerHTML='<div style=float:left>' + $id('searchpageBottom').innerHTML+'</div><div class=\"clear\"></div>';}");
		submit_disable(theform);
	}
	</script>
<div id="searchPage">
	<%
	Dim HomeUrl
	HomeUrl = LD_GetUrl(1) & "search/search.aspx?a=1"
	Dim MyProxy
	Set MyProxy = New Proxy_Class
	MyProxy.GetBody(HomeUrl)
	Set MyProxy = Nothing
%>
</div>
<div id="errorstr"></div>
<%
	

End Function

Sub DisplaySearchForm


	If DEF_BBS_SearchMode = 0 Then Exit Sub
	If Request("key") <> "" Then Exit Sub

	Dim ModeStr
	ModeStr = Request("mode")%>
	
	<script language=javascript>
	<!--
	var ValidationPassed = true;
	function submitonce(theform)
	{	
		
		if(theform.key.value=="")
		{
			alert("请输入要搜索的内容！\n");
			ValidationPassed = false;
			theform.key.focus();
			return;
		}
		else
		{ValidationPassed = true;
		}
		submit_disable(theform);
	}
	//-->
	</script>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
	<tr class=tbinhead>
		<td><div class=value><%If DEF_UsedDataBase = 0 and DEF_BBS_SearchMode = 2 Then%><b>论坛全文搜索</b>
		<%Else%><b>论坛模糊查询</b><%End if%>
		</div>
		</td>
	</tr>
	<tr>
		<td class=tdbox>
			<form name=sform id=sform action=Search.asp onSubmit="submitonce(this);return ValidationPassed;">
				<br>
				<div class=value2>搜索范围：<%
				If DEF_UsedDataBase = 0 and DEF_BBS_SearchMode = 2 Then
					If ModeStr = "" Then ModeStr = "1"%>
					<input name=mode class=fmchkbox type=radio value=1<%
					If Sch_AncTitle = 0 Then
						Response.Write " disabled"
					Else
						If ModeStr = "1" Then Response.Write " checked"
					End If
					%>>帖子名称
					<input name=mode class=fmchkbox type=radio value=2<%
					If Sch_AncContent = 0 Then
						Response.Write " disabled"
					Else
						If ModeStr = "2" Then Response.Write " checked"
					End If
					%>>帖子内容
					<input name=mode class=fmchkbox type=radio value=0<%
					If Sch_AllContent = 0 Then
						Response.Write " disabled"
					Else
						If ModeStr = "0" Then Response.Write " checked"
					End If%>>全部
					<input name=mode class=fmchkbox type=radio value=3<%
					If ModeStr = "3" Then Response.Write " checked"%>>帖子作者
					<br>
				<%Else
					If ModeStr = "" Then ModeStr = "0"
					%><input name=mode class=fmchkbox type=radio value=0<%
					If Sch_AncTitle = 0 Then
						Response.Write " disabled"
					Else
						If ModeStr = "0" Then Response.Write " checked"
					End If
					%>>帖子名称
					<input name=mode class=fmchkbox type=radio value=1<%If ModeStr = "1" Then Response.Write " checked"%>>帖子作者
					<div class=value2>
					搜索论坛：<!--#include file="../inc/incHTM/BoardForMoveList.asp"-->						
					</div>
				<%End If%>
				</div>
				<br>
				<div class=value2>搜索内容： <input value="<%=htmlencode(Request("key"))%>" type="text" name=key size=22 maxlength=255 class='fminpt input_3'>
				</div>
				<br>
				<div class=value2><input name=submit2 type=submit value="搜索" class="fmbtn btn_2"></div>
			</form>
		</td>
	</tr>
	</table>
	<%

End Sub

Sub CheckSearchLimit

	If GBL_UserID < 1 Then
		GBL_CHK_TempStr = "请确认你的身份，只有注册用户才能搜索论坛。"
		Exit Sub
	Else
		If GBL_CHK_OnlineTime < DEF_NeedOnlineTime Then
			GBL_CHK_TempStr = "你的在线时间(" & DEF_PointsName(4) & ")不足，只有在线时间超过" & DEF_NeedOnlineTime & "秒的用户才能使用此功能。"
			Exit Sub
		End If
	End If

End Sub

Sub Main

	initDatabase()
	GBL_CHK_TempStr = ""
	BBS_SiteHead DEF_SiteNameString & " - 论坛搜索",0,"论坛搜索"
	UpdateOnlineUserAtInfo 0,"论坛搜索"

	if Sch_AllContent <> 98 and Sch_AllContent <> 99 then CheckSearchLimit

	GBL_NoneLimitFlag = CheckSupervisorUserName()
	
	UserTopicTopInfo("forum")
	If GBL_CHK_TempStr = "" Then
		LoginAccuessFul()
	Else
		GBL_SiteBottomString = ""
		Global_ErrMsg GBL_CHK_TempStr
	End If
	closeDataBase()
	UserTopicBottomInfo()
	SiteBottom()

End Sub

Main()
%>