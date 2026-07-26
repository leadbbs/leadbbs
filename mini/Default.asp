<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_popfun.asp"-->
<%DEF_BBS_HomeUrl = "../"%>
<!--#include file="inc/Mini_Board.asp"-->
<!--#include file="inc/Mini_Announce.asp"-->
<!--#include file="../article/inc/splitpage_fun.asp"-->
<!--#include file="../article/inc/form_fun.asp"-->
<!--#include file="../inc/Limit_Fun.asp"-->
<!--#include file="../inc/UBBCode_Setup.asp"-->
<!--#include file="../inc/User_Setup.asp"-->
<%
dim Form_UpFlag,init_Upload
Form_UpFlag = 0
init_Upload = 0

If Request.QueryString("dontRequestFormFlag") = "" Then
		Form_UpFlag = 0
Else
	Form_UpFlag = 1
end if

Function GetFormData(name)

	If Form_UpFlag = 0 Then
		GetFormData = Request.form(name)
	Else
		if init_Upload = 1 then GetFormData = Form_UpClass.form(name)
	End If
	If GetFormData = "" Then GetFormData = Request.QueryString(name)

End Function

Sub Page_Expires

	Response.Expires = 0
	Response.ExpiresAbsolute = DEF_Now - 1
	Response.AddHeader "pragma","no-cache"
	Response.AddHeader "cache-control","private" 
	Response.CacheControl = "no-cache"

End Sub

Class Mini_Parameter

	Public BoardID,page,Action,ID,backPage,TopicID,TopicName

	'初始化全局变量，从地址栏获取全部参数
	Private Sub Class_Initialize
		BoardID = 0
		page = 0
		Action = "h"

		BoardID = toNum(Request.QueryString("b"),0)
		Action = FormClass_CheckFormValue(left(Request.QueryString("action"),1),"是否在相关页列出此分类：","string","h","a|b|h|l|r|p",2)
		page = toNum(Request.QueryString("page"),0)
		If BoardID > 0 Then
			GBL_board_ID = BoardID
			Call Borad_GetBoardIDValue(GBL_board_ID)
		End If
		ID = toNum(Request.QueryString("ID"),0)
		backPage = toNum(Request.QueryString("backPage"),0)
	
	End Sub
	
	'根据变量重新生成新的地址栏参数
	Public Function GetPar(BoardID,ID,bPage,p,Act)
	
		GetPar = "Action=" & Act & "&b=" & BoardID
		If ccur(ID) > 0 Then GetPar = GetPar & "&id=" & ID
		If bPage > 0 then GetPar = GetPar & "&backPage=" & bPage
		If p > 0 then GetPar = GetPar & "&page=" & p
	
	End Function

End Class

Class Mini_DisplayBoard

	Private LoopN,LowBoardString,LastAssosrt,CurrentAssosrt

	Private Sub Class_Initialize
	
		LoopN = 0
		LowBoardString = ""
		LastAssosrt = 0
		CurrentAssosrt = 0
	
	End Sub
	
	'显示论坛列表
	Public Sub BoardList()
	
		Dim Rs,GetData,BoardNum
		Set Rs = LDExeCute("Select BoardID,BoardAssort,BoardName,BoardIntro,LastWriter,LastWriteTime,TopicNum,AnnounceNum,ForumPass,HiddenFlag,LastAnnounceID,LastTopicName,MasterList,BoardLimit,LeadBBS_Assort.AssortID,LeadBBS_Assort.AssortName,LowerBoard,TodayAnnounce from LeadBBS_Boards left join LeadBBS_Assort on LeadBBS_Assort.AssortID=LeadBBS_Boards.BoardAssort where LeadBBS_Boards.ParentBoard=0 and LeadBBS_Boards.HiddenFlag = 0 order by LeadBBS_Boards.BoardAssort,LeadBBS_Boards.OrderID ASC",0)
		If Not Rs.Eof Then
			GetData = Rs.GetRows(-1)
			BoardNum = Ubound(GetData,2)
		Else
			BoardNum = -1
		End If
		Rs.Close
		Set Rs = Nothing
	
		'on error resume next
		Dim TempStr
		TempStr = ""
	
		%>
		<div class="board-list">
		<%
	
		If BoardNum = -1 Then
		Else
			Dim CurrentAssosrt,N
			CurrentAssosrt = -1183
			Dim LastAssosrt,WriteStr
			LastAssosrt = cCur(GetData(1,BoardNum))
			Dim LastFlag
			For N = 0 to BoardNum
				WriteStr = ""
				If CurrentAssosrt<>cCur(GetData(1,N)) Then
					CurrentAssosrt = cCur(GetData(1,N))
					'Response.Write "<li class=boardtitle>" & WriteStr & KillHTMLLabel(GetData(15,N)) & "</li>" & VbCrLf
					If N > 0 Then
					%>
		            </ul>
					<%
					end if
					%>
		                <h1>
		                  	<%=WriteStr & KillHTMLLabel(GetData(15,N))%>
		                </h1>
					  <ul data-role="listview">
					<%
				End If
				WriteStr = WriteStr & KillHTMLLabel(GetData(2,N))
				'If StrLength(WriteStr) > 21 Then
				'	WriteStr = LeftTrue(WriteStr,18) & "..."
				'End If
				GetData(17,n) = cCur(GetData(17,n))
				%>
             <li>
             <a href="Default.asp?<%=M_Par.GetPar(GetData(0,N),0,0,0,"b")%>"><h2><%=WriteStr%><%If GetData(17,n) > 0 Then Response.Write " (<small>" & GetData(17,n) & "</small>)"%></h2></a> 
             </li>
				<%
				LowBoardString = ""
				LoopN = 0
				GetLowBoardString_Move GetData(16,n)
				If LowBoardString <> "" Then Response.Write LowBoardString
				
			Next
			%>
			</ul>
			<%
		End If
	
		%>
		</div>
		<%
	
	End Sub
	
	Public Function GetLowBoardString_Move(LowBoardStr)
	
		If LowBoardStr = "" or isNull(LowBoardStr) or LoopN > 100 Then Exit Function
		LoopN = LoopN + 1
		Dim BoardNum,LowArray,N
		LowArray = Split(LowBoardStr,",")
		BoardNum = Ubound(LowArray,1)
	
		Dim Temp
		Dim WriteStr
		For N = 0 to BoardNum
			Temp = Application(DEF_MasterCookies & "BoardInfo" & LowArray(N))
			If isArray(Temp) = False Then
				Call ReloadBoardInfo(LowArray(N))
				Temp = Application(DEF_MasterCookies & "BoardInfo" & LowArray(N))
			End If
			If isArray(Temp) = True Then
				If Temp(8,0) = 0 Then
					If N >= BoardNum Then
						If LastAssosrt = CurrentAssosrt Then
							WriteStr = "" & replace(String(LoopN, "│"),"│","<span class=blockquote></span>") & ""
						Else
							WriteStr = "" & replace(String(LoopN, "│"),"│","<span class=blockquote></span>") & ""
						End If
					Else
						If LastAssosrt = CurrentAssosrt Then
							WriteStr = ""
						Else
							WriteStr = "" & replace(String(LoopN, "│"),"│","<span class=blockquote></span>") & ""
						End If
					End If
					WriteStr = WriteStr & KillHTMLLabel(Temp(0,0))
					'If StrLength(WriteStr) > 21 Then
					'	WriteStr = LeftTrue(WriteStr,18) & "..."
					'End If
					LowBoardString = LowBoardString & "<li><a href=Default.asp?" & M_Par.GetPar(LowArray(N),0,0,0,"b") & "><h2>&nbsp; &nbsp; " & WriteStr & "</h2></a></li>" & VbCrLf
					GetLowBoardString_Move Temp(27,0)
				End If
			End If
		Next

		LoopN = LoopN - 1
		
	End Function
	
	

End Class

Class Mini_PageDefine

	'显示页面头部代码
	Public Sub PageHead(BoardID,s,headStr)
		dim tmp,str
		select case M_Par.Action
			case "a":
				tmp = "b&b=" & gbl_board_id
			case "b":
				tmp = "h"
			case "l","r","p":
				if gbl_board_id > 0 then
					tmp = "b&b=" & gbl_board_id
					if M_Par.TopicID > 0 then
						tmp = "a&b=" & gbl_board_id & "&id=" & M_Par.TopicID
					else
						if M_Par.ID > 0 then
							tmp = "a&b=" & gbl_board_id & "&id=" & M_Par.ID
						end if
					end if
				else
					tmp = "h"
				end if
			case else
				M_Par.Action = "h"
				tmp = "h"
		end select
	
		str = s
		if str = "" then str = GBL_Board_BoardName
%>

<!DOCTYPE html>
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=gbk" />
<meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no"/>
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="MobileOptimized" content="240"/>
<meta name="Iphone-content" content="320"/>
<meta name="format-detection" content="telephone=no" />
	<meta name="format-detection" content="telephone=no"/>
	<meta name="description" content="<%if headStr <> str and headStr <> "" then%><%=htmlencode(KillHTMLLabel(headStr))%> - <%end if%><%=htmlencode(KillHTMLLabel(str))%>" />
	<title>
		<%=KillHTMLLabel(headStr)%> - Powered by <%=DEF_Version%>
	</title>
<link rel="stylesheet" type="text/css" href="inc/jquery.mobile.css<%=DEF_Jer%>" />
<link rel="stylesheet" type="text/css" href="inc/style_mini.css<%=DEF_Jer%>" />
<script src="../inc/js/jquery.js<%=DEF_Jer%>" type="text/javascript"></script>
<script src="../inc/js/common.js<%=DEF_Jer%>" type="text/javascript"></script>
<script type="text/javascript">
    $(document).on("mobileinit", function(){
        $.mobile.defaultPageTransition = 'slide';
        $.mobile.loadingMessage = false;
    });
</script>
<script src="inc/jquery.mobile.js" type="text/javascript"></script>


	<script>$(document).bind("mobileinit", function() {
			// disable ajax nav
			//$.mobile.ajaxEnabled=false
		});
	</script>
</head>

<body>
<a name=top></a>
<div data-role="page" id="pageone" data-title="<%if headStr <> str and headStr <> "" then%><%=htmlencode(KillHTMLLabel(headStr))%> - <%end if%><%=htmlencode(KillHTMLLabel(str))%>">
            <div  id="header" data-role="header" data-fullscreen="true" class="ui-shadow ui-header ui-bar-a">
    <h1><%=Str%></h1>
    <%
	if M_Par.Action <> "h" then%>
		<a class="button" href="default.asp?action=<%=tmp%>" data-direction="reverse" id="returnUR">返回</a>
	<%
	else
			if request.querystring("new") = "1" then
				%>
				<a class="button" href="default.asp?action=<%=tmp%>" data-direction="reverse" id="returnUR">返回</a>
				<%
			else
				%>
				<a class="button" href="default.asp?action=b&new=1">新帖</a>
				<%
			end if
	end if
	if gbl_userid <= 0 then
	%><a class="ui-btn-right" href="default.asp?action=l&b=<%=gbl_board_id%>" data-ajax=false>
                        登录/注册
                    </a>
	<%
	else
		if M_Par.Action <> "h" and gbl_board_id > 0 and M_Par.Action <> "p" then%>
	<a class="ui-btn-right" href="default.asp?action=p&b=<%=gbl_board_id%>&id=<%=M_Par.ID%>" data-ajax=false>
                        <%If M_Par.ID > 0 then
                        	response.write "回复"
                        else
                        	response.write "发帖"
                        end if%>
                    </a>
	<%
		end if
	end if
%>
</div>
<%
if M_Par.Action = "a" then%>
<div class="threadhead">
        <h1>
        	                        
            <a href="default.asp?action=a&b=<%=gbl_board_id%>&id=<%=M_Par.ID%>" id="thread_subject" >
            <%=htmlencode(headStr)%>
            </a>
         </h1>
 </div>
<%end if%>


<%

	End Sub

	'显示页面尾部代码
	Public Sub PageBottom

		Mini_Spend()

	End Sub
	
	
	Private Sub Mini_Spend
	
		%>
		<div id="bbsMobileFooter">
    <p>
    <%=FullStr%>
    <%Response.Write " Page created in " & FormatNumber(cCur(Timer - DEF_PageExeTime1),4,True) & " seconds width " & GBL_DBNum & " queries."%>
    </p>
        <h3>
				<div class="createtime">
				<%'if OPEN_DEBUG = 1 and DEBUG_User = GBL_CHK_User Then 
%>
				<div style="text-align:left;background:white;color:black;display:1none;"><ul><%=sqlstring%></ul></div>
				<%'End If
%>
				</div>
<div id="bottom_ad">
	<%'Response.Write "<!--"
%>
	<!--#include file="../inc/incHtm/Bottom_AD.asp"-->
	<%'Response.Write "-->"
%>
	</div>
        </h3>
</div>
<%
Call tips_out()
Call getinfo()
%>
		</body>
		</html>
		<%
	
	End Sub
	
	Public Sub LoginForm
	
		If GetFormData("submit") = "1" then
			If GBL_UserID > 0 then
				response.redirect "default.asp?" & Timer
			else
				If GBL_CHK_Tempstr = "" then GBL_CHK_Tempstr = "登录失败，请仔细输入用户名和密码．"
			end if
		end if
	%>
	<div class="ui-content" data-role="content">
	
	    	<a data-icon="star"><%=GBL_CHK_Tempstr%></a>
	    	<form id="leadform" action="default.asp?action=l&submit=1" method="POST" data-ajax="true">
	    	<input name="user" placeHolder="账号" type="text" data-theme="x" class="usernameInput" />
   		<input name="pass" placeHolder="密码" type="password" data-theme="x" class="passwordInput"/>
	   	 	<input name=submitflag type=hidden value="ddddls-+++">
	   	 	<input type="checkbox" name="CkiExp" id="remember" data-inline="true" data-theme="x" value="7">
        		<label for="remember">记住我</label>
				<input class="formSubmit" href="#" data-role="button" data-inline="false" value="立即登录" type="submit" data-theme=x-master>
			</form>
			<a id="loginButton" class="formSubmit" href="default.asp?action=r" data-role="button" data-theme=x-master>注册新用户</a>
	
	
	
	        <%If GetBinarybit(DEF_Sideparameter,10) = 1 Then%>
<p class="separator"><span>或使用合作网站帐号登录</span></p>
<div class="third-part-login">
<a id="qq_log" data-role="button" data-theme=x data-inline=true href="javascript:;" onclick="document.location.href='<%=DEF_BBS_HomeUrl%>app/qqlogin/login.asp?u=<%=urlencode(Request.Servervariables("SCRIPT_NAME"))%>';" data-ajax=false><img src="<%=DEF_BBS_HomeUrl%>images/app/big_1.png" border="0" alt="qq" /></a>
</div>
<%
End If%>
	</div>
	<%
	End Sub
	
	Public Sub RegForm
	
	%>
<script type="text/javascript"> 
	var ValidationPassed = true,submitflag=0;
	function submitonce(theform)
	{	submitflag = 1;
		<%If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then%>
		
		if(theform.ForumNumber.value=="")
		{
			alert("请输入验证码!\n");
			ValidationPassed = false;
			theform.ForumNumber.focus();
			submitflag = 0;
			return;
		}
		<%End If%>

		ValidationPassed = true;
		submit_disable(theform);
	}
	
$(document).ready(function() 
{ 
$('#LeadBBSFm').submit(function()
{
submitonce(this);
if(ValidationPassed==false)return false;
var options = { 
target:'#return', 
url:$('#LeadBBSFm').attr("action")+"?ajaxflag=1", 
contentType: "application/x-www-form-urlencoded; charset=utf-8",
data: $('#LeadBBSFm').serialize(),
type:'POST', 
success: function (data) {
								if(data=="ok"||data.substr(0,7)=="success")
                        {
                        	$("#return").html("<div class=bbs_ok>操作完成，<a href=javascript:; onclick=location.reload()>点此刷新．</div>");
                        	resetAnnounce();
                        	
                        }
                        else
                        {
                        $("#return").html("<div class=bbs_error>" + data + "</div>");
                        if(data.indexOf("script") == -1)alert($("#return").text());
                        }
                        
                       
                        submit_disable($id('LeadBBSFm'),1);
                     },
error: function(data) {
                         alert("error:"+data.responseText);
                         $("#return").html("<div class=bbs_error>" + data.responseText + "</div>");
                         submit_disable($id('LeadBBSFm'),1);
                      }

};
$.ajax(options); 
return false; 
}); 
} 
);

function resetAnnounce()
{
	edit_clear();
	if($id("ForumNumber"))
	{
		$("#ForumNumber").val("");
		$("#verifycode").attr("src",$("#verifycode").attr("src")+"&1");
	}
}
</script> 
	    <div class="ui-content" data-role="content">
	
	    	<a data-icon="star"><%=GBL_CHK_Tempstr%></a>
	    	<form action=<%=DEF_BBS_HomeUrl%>user/<%=DEF_RegisterFile%> method=post name=LeadBBSFm id="LeadBBSFm" data-ajax="true">
				<input name="action" type="hidden" value="">
				<input name="command" type="hidden" value="">
				<input name="u" type="hidden" value="<%=ld_geturl(1)%>mini/default.asp">
				<input class=fminpt name=SubmitFlag type=hidden value="29d98Sasphouseasp8asphnet">
				<input class=fminpt name=JoinFlag type=hidden value="3kkdk">

												<%
												dim ShowTestNumber
												If Def_UserTestNumber = 2 Then
													ShowTestNumber = 0
												ElseIf Def_UserTestNumber = 1 Then
													If DEF_EnableAttestNumber = 1 Then
														ShowTestNumber = 3
													Else
														ShowTestNumber = 4
													End If
												Else
													ShowTestNumber = DEF_EnableAttestNumber
												End If
												If ShowTestNumber > 2 Then%>
												<div data-role="fieldcontain">
																				<i>* </i>验证码<br />
																<label id="loginform_ShowTestNumber">
																	<%Response.Write displayVerifycode()%>
																</label>
												</div>
												<%End If%>
												<input name="Form_username" placeHolder="账号" type="text" data-theme="x" class="usernameInput" />
												
												<input name="Form_password1" maxlength="14" placeHolder="密码" type="password" data-theme="x" />
												<input name="Form_password2" maxlength="32" placeHolder="重复密码" type="password" data-theme="x" />
												<input name="Form_mail" id="loginform_email" maxlength="100" placeHolder="电子邮件" type="text" data-theme="x" />
												<input name="Form_Question" id="loginform_sel_question" maxlength="32" placeHolder="问题提示(任意填写)" type="text" data-theme="x" />
												<input name="Form_Answer" id="loginform_Form_Answer" maxlength="32" placeHolder="问题答案" type="text" data-theme="x" />
												<input name="Form_OICQ" id="loginform_qq" maxlength="32" placeHolder="QQ(可不填写)" type="text" data-theme="x" />
												<input name="Form_MobileTel" id="loginform_mobiletel" maxlength="32" placeHolder="手机号码(可不填写)" type="text" data-theme="x" />

												
												<div class="alert" id="return" style="text-align:center;margin-top:12px;"></div>
												<input class="formSubmit" href="#" data-role="button" data-inline="false" value="立即注册" type="submit" data-theme=x-master>
			</form>
	</div>
	<%
	End Sub
	
	public Sub Error(str)
	%>
		<div class=error><%=str%>
		<div class=clear></div>
			<a href=javascript;; data-role="button" data-ajax=false data-rel="back" data-inline="true">返回</a>
		</div>
	<%
	End sub
	
	public function getAnnounceTopic(id)
	
		dim rs,pid,boardid
		pid = 0
		boardid = 0
		M_Par.TopicID = id
		set rs = ldexecute("select title,parentid,boardid,rootidbak from leadbbs_announce where id=" & id,0)
		if not rs.eof then
			getAnnounceTopic = rs(0)
			pid = ccur(rs(3))
			boardid = ccur(rs(2))
		else
			getAnnounceTopic = ""
		end if
		rs.close
		set rs = nothing
		if pid > 0 then
			set rs = ldexecute("select title,parentid,boardid,rootidbak from leadbbs_announce where id=" & pid,0)
			if not rs.eof then
				getAnnounceTopic = rs(0)
				boardid = ccur(rs(2))
				M_Par.TopicID = pid
			else
				getAnnounceTopic = ""
			end if
			rs.close
			set rs = nothing
		end if
		if boardid <> gbl_board_id then
			gbl_board_id = boardid
			Call Borad_GetBoardIDValue(gbl_board_id)	'was GetBoardIDValue(): no such routine (typo) -- silently did nothing
			gbl_chk_tempstr = ""
			Call CheckAccessLimit()
			if gbl_chk_tempstr <> "" then getAnnounceTopic = ""
		end if
	
	end function
	
	Public Sub AnnounceForm(ID,TN)

		dim RID,TopicName
		TopicName = TN
		RID = ID
		if RID = -1 then
			RID = M_Par.ID
			if RID > 0 then
				TopicName = getAnnounceTopic(RID)
			end if
		end if
		%>
		<div class=clear></div>
	<div class="ui-content" data-role="content">
		<a name=name></a>
		<%
		If GBL_CHK_User = "" Then
		%>
		<h2>
		登录才能发帖，<a href="default.asp?action=l"><点此登录></a> / <a href="default.asp?action=r"><点此注册></a>
		</h2>
		<%
		Else%>
		欢迎 <%=htmlencode(GBL_CHK_User)%> 发表<%If RID = 0 Then%>新帖<%Else%>回复<%End If%>
		<%
		End If
	%><div id="return"></div>

        <form action="<%=DEF_BBS_HomeUrl%>a/a2.asp" data-ajax=false method="post" id="LeadBBSFm" name="LeadBBSFm">
       <div class="inbox bt mtn">
        <%If TopicName <> "" Then%>
        		<input maxlength="255" type="text" name="Form_Title" class="txt" size="25" value="<%Response.Write "Re:" & htmlencode(KillHTMLLabel(TopicName))%>" placeholder="标题" />
				<%Else%>
				<input maxlength="255" type="text" name="Form_Title" value="" class="txt" size="25" placeholder="标题" />
				<%End If%>
			</div>
				<div class=clear></div>
			<div class="inbox">
                <textarea name="Form_Content" cols="24" rows="5" id="e_textarea" class="txt" ></textarea>
			</div>
            <%If GBL_CHK_User <>"" Then%>
            <input name="submitflag" value="true" type="hidden" />
            <input name="LMT_DefaultEdit" value="1" type="hidden" />
            <input name="BoardID" value="<%=GBL_board_ID%>" type="hidden" />
				<input name="ID" value="<%=RID%>" id="anc_rid" type="hidden" />
				<input type="hidden" name="Form_HTMLFlag" value="2" />
				
			
				<%
				If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then%>
				
				<div class="inbox bt mtn">
				<div style="line-height:400%;display:inline-block;">验证码
				<%
					Response.Write displayVerifycode()%></div>
				</div><%
				End If%>
				<div class=clear></div>
            <input class="formSubmit" href="#" data-role="button" data-inline="false" value="发表" type="submit" data-theme=x-master>
            <%End If%>
        </form>
	</div>
<script type="text/javascript">
<!--
	var ValidationPassed = true,submitflag=0;
	function submitonce(theform)
	{	submitflag = 1;
		<%If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then%>
		
		if(theform.ForumNumber.value=="")
		{
			alert("请输入验证码!\n");
			ValidationPassed = false;
			theform.ForumNumber.focus();
			submitflag = 0;
			return;
		}
		<%End If%>

		ValidationPassed = true;
		submit_disable(theform);
	}
-->
</script>
<script type="text/javascript"> 

$(document).ready(function() 
{ 
$('#LeadBBSFm').submit(function()
{
submitonce(this);
if(ValidationPassed==false)return false;
var options = { 
target:'#return', 
url:$('#LeadBBSFm').attr("action")+"?ajaxflag=1", 
contentType: "application/x-www-form-urlencoded; charset=utf-8",
data: $('#LeadBBSFm').serialize(),
type:'POST', 
success: function (data) {
								if(data=="ok"||data.substr(0,7)=="success")
                        {
                        	$("#return").html("<div class=bbs_ok>成功发表，<a href=javascript:; data-ajax=false onclick=location.reload()>点此刷新．</a></div>");
                        	$.mobile.changePage($("#returnUR").attr("href"));
                        	resetAnnounce();
                        	
                        }
                        else
                        alert($("#return").html("<div class=bbs_error>" + data + "</div>").text());
                        
                       
                        submit_disable($id('LeadBBSFm'),1);
                     },
error: function(data) {
                         alert("error:"+data.responseText);
                         submit_disable($id('LeadBBSFm'),1);
                      }

};
$.ajax(options); 
return false; 
}); 
} 
);

function resetAnnounce()
{
	$("#Form_Content").val("");
	if($id("ForumNumber"))
	{
		$("#ForumNumber").val("");
		$("#verifycode").attr("src",$("#verifycode").attr("src")+"&1");
	}
}
</script> 

	<%
	End Sub

End Class

Dim M_Par
Dim MiniPageDefine
Dim FullStr

Sub Main

	Page_Expires()
	initDatabase()
	Set M_Par = New Mini_Parameter
	Set MiniPageDefine = New Mini_PageDefine
	
	Select Case M_Par.Action

		Case "a"
			Dim M_Anc
			Set M_Anc = New Mini_Announce
			M_Anc.GetTopicInfo
			MiniPageDefine.PageHead M_Par.BoardID,GBL_Board_BoardName,M_Anc.LMT_TopicName
			M_Anc.DisplayTopic
			Set M_Anc = Nothing
			
			FullStr = "<a href=""../a/" & RW_a(M_Par.BoardID,M_Par.ID,M_Par.Page+1,M_Par.backPage+1,"")
			FullStr = FullStr & """ id=""goToWeb"" data-ajax=false>电脑版</a>"
				
		Case "b"
			Dim M_Board
			Set M_Board = New Mini_Board
			if request.querystring("new") = "1" then
				MiniPageDefine.PageHead 0,"最新帖子",""
				M_Board.List(1)
			else
				MiniPageDefine.PageHead M_Par.BoardID,"",GBL_Board_BoardName 
				M_Board.List(0)
			end if
			Set M_Board = Nothing
			
			FullStr = "<a href=""../b/" & RW_b(M_Par.BoardID,M_Par.page,"")
			FullStr = FullStr & """ id=""goToWeb"" data-ajax=false>电脑版</a>"
		case "l"
			MiniPageDefine.PageHead M_Par.BoardID,"登录","登录"
			MiniPageDefine.LoginForm
			FullStr = "<a href=""../Boards.asp?homesel=1"" id=""goToWeb"" data-ajax=false>电脑版</a>"
		case "r"
			MiniPageDefine.PageHead M_Par.BoardID,"注册新用户","注册新用户"
			MiniPageDefine.RegForm
			FullStr = "<a href=""../Boards.asp?homesel=1"" id=""goToWeb"" data-ajax=false>电脑版</a>"
		case "p"
			if M_Par.ID > 0 then M_Par.TopicName = MiniPageDefine.getAnnounceTopic(M_Par.ID)
			MiniPageDefine.PageHead M_Par.BoardID,"发帖","发帖"
			call MiniPageDefine.AnnounceForm(-1,"")
			FullStr = "<a href=""../Boards.asp?homesel=1"" id=""goToWeb"" data-ajax=false>电脑版</a>"
		Case Else
			MiniPageDefine.PageHead M_Par.BoardID,"<img id=""leadbbs_logo"" src=""" & ld_geturl(1) & "mini/inc/images/logo.png"">",DEF_SiteNameString
			Dim MiniBoard
			Set MiniBoard = New Mini_DisplayBoard
			MiniBoard.BoardList
			Set MiniBoard = Nothing

			FullStr = "<a href=""../Boards.asp?homesel=1"" id=""goToWeb"" data-ajax=false>电脑版</a>"
	End Select

	CloseDatabase()
	Set M_Par = Nothing
	MiniPageDefine.PageBottom
	Set MiniPageDefine = Nothing

End Sub

Main()


sub getinfo

%>
<script>
$(document).ready(function() {
var v = window.screen.width +","+window.screen.height
$.ajax({url:"../user/lookuserinfo.asp?Evol=remark&remark="+v,async:false});
});
</script>
<%
end sub
%>