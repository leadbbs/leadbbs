<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="../inc/Limit_Fun.asp"-->
<!--#include file="inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
checkSupervisorPass()
If Replace(LCase(DEF_Version) & ""," ","") <> "leadbbs9.2" Then
	CALL LDExeCute("Update LeadBBS_SiteInfo Set Version='" & chr(76)&chr(101)&chr(97)&chr(100)&chr(66)&chr(66)&chr(83)&chr(32)&chr(57)&chr(46)&chr(50) & "'",1)
	ReloadVesion()
End If

GBL_ID = GBL_UserID

Dim GBL_InPageFlag
' README §51: with no key, Request.QueryString is an OBJECT here, not its string value, so
' comparing it to "" is ALWAYS True. GBL_InPageFlag was therefore never 0 and the admin
' SHELL -- top tabs, left nav, content iframe -- was never rendered: every page came back as
' the bare inner panel. Concatenating an empty string coerces it.
If (Request.QueryString & "") <> "" Then
	GBL_InPageFlag = 1
Else
	GBL_InPageFlag = 0
End If

If GBL_InPageFlag = 1 Then
	Manage_sitehead DEF_SiteNameString & " - 管理员",""
Else
	Manage_sitehead DEF_SiteNameString & " - 管理员","frame_class"
End If

If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
	DisplayLoginForm()
End If
closeDataBase()
Manage_Sitebottom("none")

Sub LoginAccuessFul


	Dim NewUrl
	NewUrl = DEF_BBS_HomeUrl
	If Left(NewUrl,3) = "../" or Left(NewUrl,3) = "..\" Then NewUrl = Mid(NewUrl,4)

	If GBL_InPageFlag = 1 Then
		Default_info()
		Exit Sub
	End If
%>

<script>
	
	var nav_cursel = null;
	function nav_sel(obj)
	{
		if(nav_cursel && nav_cursel!=null && nav_cursel.parentNode)nav_cursel.parentNode.className="item";
		nav_cursel = obj;
		obj.parentNode.className="item_sel";
	}
	var nav_curassort = null;
	function nav_assortsel(n)
	{
		$id('nav_itemlist1').style.display="none";
		if(nav_curassort!=null)$id('nav_assort_' + nav_curassort).className="item";
		nav_curassort = n;
		$id('nav_assort_' + n).className="item_sel";
		$id('nav_itemlist0').innerHTML = $id('nav_itemlist' + n).innerHTML;
		nav_sel($id('nav_itemlist' + n + '_default'));
		$id('mainFrame').src = $id('nav_itemlist' + n + '_default').href;
	}
	//document.body.onselectstart = document.body.ondrag = function(){
    //return false;
	//}
	
	
	function refresh_info()
	{
		$.ajax({url:"BlockUpdate/Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>",async:false,success:function(d){
		setTimeout(refresh_info, 60000);}
		});
	}
	$(document).ready(function() {
	setTimeout(refresh_info, 60000);
	});
</script>



	<div class="frame_top" id="topDataTd">
			<div class=managelogo><img src=pic/manage_title.gif></div>
			<div class=top_control>
				<a href="<%=NewUrl%>Default.asp?action=info" id="nav_assort_1" class="item_sel" target="mainFrame" onclick="nav_assortsel(1);">首页</a>
				<a href="javascript:;" id="nav_assort_2" class="item" target="mainFrame" onclick="nav_assortsel(2);">版面分类</a>
				<a href="javascript:;" id="nav_assort_3" class="item" target="mainFrame" onclick="nav_assortsel(3);">版面</a>
				<a href="javascript:;" id="nav_assort_4" class="item" target="mainFrame" onclick="nav_assortsel(4);">用户</a>
				<a href="javascript:;" id="nav_assort_5" class="item" target="mainFrame" onclick="nav_assortsel(5);">数据库</a>
				<a href="javascript:;" id="nav_assort_6" class="item" target="mainFrame" onclick="nav_assortsel(6);">风格</a>
				<a href="javascript:;" id="nav_assort_7" class="item" target="mainFrame" onclick="nav_assortsel(7);">广告</a>
				<a href="javascript:;" id="nav_assort_8" class="item" target="mainFrame" onclick="nav_assortsel(8);">功能</a>
				<a href="javascript:;" id="nav_assort_9" class="item" target="mainFrame" onclick="nav_assortsel(9);">CMS</a>
			</div>
			
		    <div class=top_userinfo>
		    	&lt;<span class=item><b><%=GBL_CHK_User%></b></span>&gt;
		    	<span class="splitword"> | </span>
		    	<a href=<%=DEF_BBS_HomeUrl%>User/BoardMaster/Default.asp class=item target=_blank><%=DEF_PointsName(6)%></a>
		    	<span class="splitword"> | </span>
		    	<a href=<%=DEF_BBS_HomeUrl%>Boards.asp class=item>返回首页</a>
		    	<span class="splitword"> | </span> 
		    	<a href=<%=DEF_BBS_HomeUrl%>User/login.asp?action=logout class=item>退出</a>
		    </div>
			
	</div>
	<div class="frame_topline">
		<div class="frame_topline1">
		</div>
			<div class="frame_topline2">				
			</div>
	</div>
	
	<div class="frame_leftbody" style="">
		<br />
		<div class="frame_leftcontent">
		<!-- README §6: Default_NavItem is defined ~350 lines below this point, and a
     parenthesis-less call to a forward-declared Sub is silently dropped, which left this
     nav column empty even once the shell started rendering. Hence Call ... () -->
		<%Call Default_NavItem()%>
		</div>
	</div>
	<div class="maincontent">
		<iframe src="Default.asp?action=info" name="mainFrame" id="mainFrame" hidefocus="" frameborder="no" scrolling="auto">
		</iframe>
	</div>
      
		
<%End Sub

Sub Default_info

	If CheckSupervisorPass() = 1 Then
		If LCase(Request.ServerVariables("QUERY_STRING")) <> "checkversion" Then
			DisplaySystemInfo()
		Else
			Response.Clear
			Update_CheckVersion()
			Response.End
		End If
	Else%>
		<p><br>
		已经成功登录！<br></p>
		<br><br>
	<%End If%>
	<br><br>

<%End Sub


Dim GBL_UpdateVersion '内部版本号
GBL_UpdateVersion = 0
Dim GBL_LeadBBS_Setup_Data '临时读取的SetupRID记录数据数组

Function DisplaySystemInfo

	frame_TopInfo()
	%>
	<div class=frametitlehead>论坛信息一览</div>
	<div class="frameline"><a href=default.asp?need=1773>点击查看组件安装情况</a></div>
	<div class="frameline">服务器时间：<%=now%>，论坛(计算时差)时间：<%=DEF_Now%></div>
	<div class="frameline">服务器类型：<%=Request.ServerVariables("OS")%>[IP:<%=Request.ServerVariables("LOCAL_ADDR")%>]</div>
	<div class="frameline">脚本解释引擎：<%=ScriptEngine & "/"& ScriptEngineMajorVersion &"."&ScriptEngineMinorVersion&"."& ScriptEngineBuildVersion %></div>
	<div class="frameline">您的IP地址：<%=GBL_IPAddress%></div>
	<div class="frameline">服务端软件：<%=Request.ServerVariables("SERVER_SOFTWARE")%></div>
	<div class="frameline">解释引擎：<%=ScriptEngine & "/"& ScriptEngineMajorVersion&"."&ScriptEngineMinorVersion&"."& ScriptEngineBuildVersion%></div>
	<%If Request.QueryString("need") = "1773" Then%>
	<div class="frameline">AspJpeg图形组件：<%
	CheckObjInstalled("Persits.Jpeg")
	Response.write GBL_CHK_TempStr%></div>
	<div class="frameline">FSO文本读写：<%
	CheckObjInstalled2(DEF_FSOString)
	Response.write GBL_CHK_TempStr%></div>
	<div class="frameline">数据库使用：<%
	CheckObjInstalled("adodb.connection")
	Response.write GBL_CHK_TempStr%></div>
	<div class="frameline">Jmail组件支持：<%
	CheckObjInstalled("JMail.SMTPMail")
	Response.write GBL_CHK_TempStr%></div>
	<div class="frameline">LeadBBS专用组件支持：<%
	CheckObjInstalled("leadbbs.bbsCode")
	Response.write GBL_CHK_TempStr%></div>
	<div class="frameline">无组件上传：Scripting.Dictionary <%
	CheckObjInstalled("Scripting.Dictionary")
	Response.write GBL_CHK_TempStr%>
	ADODB.Stream <%
	CheckObjInstalled("ADODB.Stream")
	Response.write GBL_CHK_TempStr%> (全部支持才能正常上传)</div>
	<%End If%>
	<div class=frametitle>LeadBBS更新检测</div>
	<div class=frameline id="check_update" onclick="this.style.display='none';update_checkversion();"><a href="javascript:;" class="bluefont">点击检测更新</a></div>
	<div class=frameline id=checkversion></div>	
	<script>
	$(document).ready(function() {
	$("#check_update").hide();
	update_checkversion();
	});
	</script>
	<br>
	<div class=frametitlehead>修改论坛默认LOGO/Banner图片,请参考原图片大小制作</div>
	<div class=frameline>
	<table>
	<tr>
		<td>
			<img src="<%=DEF_BBS_HomeUrl%>images/style/extend/01002/logo.png">
		</td>
		<td>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=images/style/extend/01002/&p_filename=logo.png&p_fileinfo=<%=urlencode("默认风格LOGO(扩展风格1002),必须是png格式")%>" target="_blank">
			点击修改 默认风格LOGO(扩展风格1002)(PNG图片)</a><br>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=images/style/extend/01002/&p_filename=logo.gif&p_fileinfo=<%=urlencode("默认风格LOGO(扩展风格1002),必须是gif格式")%>" target="_blank">
				点击修改 默认风格LOGO(扩展风格1002)(GIF图片,为兼容IE6)
			</a>
		</td>
	</tr>
	<tr><td colspan="2"><hr class=splitline></td></tr>
	<tr>
		<td>
			<img src="<%=DEF_BBS_HomeUrl%>images/100.jpg">
		</td>
		<td>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=images/&p_filename=100.jpg&p_fileinfo=<%=urlencode("帖子信息引用LOGO(必须是jpg格式)")%>" target="_blank">
				点击修改 帖子信息引用LOGO(必须是jpg格式)
			</a>
			<br>
			<span class="grayfont">注释: 若你使用了新的CSS样式定义图片,此修改可能会失效,请参考新的css</span>
		</td>
	</tr>
	<tr><td colspan="2"><hr class=splitline></td></tr>
	<tr>
		<td>
			<img src="<%=DEF_BBS_HomeUrl%>images/style/extend/01002/banner.png">
		</td>
		<td>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=images/style/extend/01002/&p_filename=banner.png&p_fileinfo=<%=urlencode("默认风格Banner图片(扩展风格1002),必须是png格式")%>" target="_blank">
			点击修改 默认风格Banner图片(扩展风格1002)(PNG图片)</a><br>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=images/style/extend/01002/&p_filename=banner.gif&p_fileinfo=<%=urlencode("默认风格Banner图片(扩展风格1002),必须是gif格式")%>" target="_blank">
				点击修改 默认风格Banner图片(扩展风格1002) (GIF图片,为兼容IE6)
			</a>
			<br>
			<span class="grayfont">注释: 若你使用了新的CSS样式定义图片,此修改可能会失效,请参考新的css</span>
			</span>
		</td>
	</tr>

	<tr><td colspan="2"><hr class=splitline></td></tr>
	<tr>
		<td>
			<img src="<%=DEF_BBS_HomeUrl%>images/logo.gif">
		</td>
		<td>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=images/&p_filename=logo.gif&p_fileinfo=<%=urlencode("默认友情链接LOGO (必须是gif格式)")%>" target="_blank">
				点击修改 默认友情链接LOGO (必须是gif格式)
			</a>
		</td>
	</tr>
	</table>
	</div>
	<div class=frametitle><a href="javascript:;" onclick="$id('moreskinimg').style.display='block';">点击修改其它风格的LOGO和Banner</a></div>
	<div class=frameline id="moreskinimg" style="display:none;">
	<table class="table_in">
	<tr><td colspan="3"><hr class=splitline></td></tr>
	<tr><td colspan="3"><span class="redfont">注: 若你修改了相应风格的css，此处修改图片可能会无效，请以自定义的css图片为准<br>
	步步惊心 及 默认设置 两个风格所对应的logo和banner同扩展风格1002,若要修改请参考 修改论坛默认LOGO/Banner图片</span></td></tr>
	<tr align="center"><td><b>风格</b></td><td><b>图片</b></td><td><b>修改</b></td></tr>
	<%
	call viewstyleimage("默认设置","images/style/extend/01002/","banner.png","Banner","png",1)
	call viewstyleimage("1","images/style/0_1/","logo.gif","logo","gif",0)
	call viewstyleimage("1","images/temp/","banner17.gif","banner","gif",0)
	call viewstyleimage("2","images/style/3/","logo.gif","logo","gif",0)
	call viewstyleimage("2","images/style/3/","banner.gif","banner","gif",0)
	%>
	<tr><td>3</td><td colspan="2">无logo图片，banner图片同风格 2共享</td></tr>
	<tr><td colspan="3"><hr class=splitline></td></tr>
	<tr><td>如初见</td><td colspan="2">无logo图片</td></tr>
	<tr><td colspan="3"><hr class=splitline></td></tr>
	<%
	call viewstyleimage("如初见","images/style/extend/01000/","banner.gif","banner","gif",0)
	call viewstyleimage("2013","images/style/extend/01001/","logo.png","logo","png",0)
	call viewstyleimage("2013","images/style/extend/01001/","banner.png","banner","png",0)
	%>
	</table>
	</div>
	
	<div class=frametitle>LeadBBS版本信息</div>
	<div class=frameline>程序制作：LeadBBS工作室，主编SpiderMan(QQ:527274)</div>
	<div class=frameline>版本信息：<a href=http://www.leadbbs.com target=_blank><b><span class=redfont><%=DEF_Version%>.<%=GBL_UpdateVersion%></span></b></a></div>
	

	<div class=frametitle>权限参考</div>
	<ol class=listli>
		<li>屏蔽用户修改权限，如果是普通用户，无权更改自己的资料及发表的帖；<%=DEF_PointsName(8)%>及以上人员，则额外限制固顶，总固顶及编辑版面帖子。</li>
		<li><%=DEF_PointsName(5)%>对任何会员都有限制(包括管理员)，<%=DEF_PointsName(5)%>专版仅拥有认证资格的人员才可以进入。</li>
		<li>权限等级排序：管理员-><%=DEF_PointsName(6)%>-><%=DEF_PointsName(8)%>->普通会员。其中<%=DEF_PointsName(5)%>属于特殊用户。</li>
		<li>禁止转移帖子功能仅对版主以上有效。</li>
		<li>默认版主拥有编辑，精华，删除，锁定，固顶版面帖权限，查看所有上传附件，发表带颜色标题帖。</li>
		<li><%=DEF_PointsName(6)%>除拥有版主的权限外，还拥有总固顶的权限。</li>
		<li>管理员拥有一切权限，可以发表html语法的主题及帖子内容，管理用户及论坛一切资料。</li>
	</ol>
	<script>
	function update_checkversion()
	{
	$id('checkversion').innerHTML = "检测中...";
	getAJAX("default.asp?checkversion","","checkversion",0);}
	</script>
	<%
	frame_BottomInfo()

End Function

sub viewstyleimage(str,imgpath,imgname,imgclass,imgtype,dflag)

%>
	<tr>
		<td>
			<%=str%>
		</td>
		<td>
			<img src="<%=DEF_BBS_HomeUrl%><%=imgpath&imgname%>">
		</td>
		<td>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=<%=imgpath%>&p_filename=<%=lcase(imgname)%>&p_fileinfo=<%=urlencode("默认风格Banner图片(扩展风格1002),必须是" & imgtype & "格式")%>" target="_blank">
			点击修改 <%=imgclass%>图片(<%=imgtype%>图片)</a>
			<%if dflag = 1 then%>
			<br>
			<a href="SiteManage/siteInfo.asp?action=upload&p_filepath=<%=imgpath%>&p_filename=<%=replace(lcase(imgname),imgtype,"gif")%>&p_fileinfo=<%=urlencode("默认风格Banner图片(扩展风格1002),必须是gif格式")%>" target="_blank">
				点击修改 <%=imgclass%> 图片 (GIF图片,为兼容IE6)
			</a>
			<%end if%>
			<br>
			<span class="grayfont">注释: 若你使用了新的CSS样式定义图片,此修改可能会失效,请参考新的css</span>
			</span>
		</td>
	</tr>
	<tr><td colspan="3"><hr class=splitline></td></tr>
<%
end sub


Sub Update_CheckVersion

	
	
	If Update_CheckSetupRIDExist(1002," and ClassNum=0") = 0 Then
		GBL_UpdateVersion = "20100101001"
	Else
		GBL_UpdateVersion = cCur(GBL_LeadBBS_Setup_Data(2,0))
	End If
	
Const NetFlag = 1
Const NetUrl = "http://update.u1.leadbbs.com/"
Const NativeDir = "Download/"
Const SplitString = "---NdetVeL---"
	Dim Update,CurFile,CurFile_Name,CurFile_Intro
	Dim FileList
	Dim m
	If NetFlag = 0 Then
		Update = ADODB_LoadFile(NativeDir & "update.txt")
	Else
		Update = BytesToBstr(Update_GetInternetFile(NetUrl & "update.txt"))
	End If
	If Update = "err" Then Exit Sub
	Update = Split(Update,VbCrLf)
	
	Dim UpdateFlag
	UpdateFlag = 0
	For M = 0 to Ubound(Update,1)
		If Trim(Update(M)) <> "" Then
			If inStr(Update(M),SplitString) > 0 Then
				CurFile = Split(Update(M),SplitString)
				CurFile_Name = CurFile(0)
				CurFile_Intro = " (" & CurFile(1) & ")"
			Else
				CurFile_Name = Update(M)
				CurFile_Intro = ""
			End If
			
			If isNumeric(CurFile_Name) = 0 Then CurFile_Name = 0
			CurFile_Name = cCur(CurFile_Name)
			If CurFile_Name > cCur(GBL_UpdateVersion) Then
				Response.Write "<div class=redfont>检测到新补丁<u>" & CurFile_Name & "</u>" & CurFile_Intro & "</div>"
				UpdateFlag = UpdateFlag + 1
			End If
		End If
	Next
	If UpdateFlag = 0 Then
		Response.Write "<div class=greenfont>您的论坛已是最新版本。</div>"
	Else
		Response.Write "<div class=redfont>共有" & UpdateFlag & "个补丁需要更新。</div>"
	End If

End Sub


Function Update_CheckSetupRIDExist(RID,extend)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,RID,ValueStr,ClassNum,SaveData from LeadBBS_Setup where RID=" & RID & extend,1),0)
	If Rs.Eof Then
		Update_CheckSetupRIDExist = 0
		Set GBL_LeadBBS_Setup_Data = Nothing
		GBL_LeadBBS_Setup_Data = ""
	Else
		Update_CheckSetupRIDExist = 1
		GBL_LeadBBS_Setup_Data = Rs.GetRows(-1)
		GBL_LeadBBS_Setup_Data(2,0) = Trim(GBL_LeadBBS_Setup_Data(2,0))
	End If
	Rs.Close
	Set Rs = Nothing

End Function

Function BytesToBstr(body) 

	on error resume next
	If LenB(body) < 1 Then
		BytesToBstr = ""
		Exit Function
	End If
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
	If Err and BytesToBstr = "" Then
		BytesToBstr = body
		Err.clear
	End If

End Function

Function Update_GetInternetFile(ur)

	Dim url
	Url = ur
	url = Left(url,5000)
	If url = "" Then Exit Function
	Dim xmlHttp
	Set xmlHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
	xmlHttp.setTimeouts 5000,5000,5000,15000
	xmlHttp.setOption 2, 13056
	xmlHttp.open "GET", url, False, "", "" 
	
	on error resume next
	xmlHttp.send()
	If Err Then
		Response.Write "<p>错误描述: <font color=red>" & err.description & "</font></p>"
		Err.clear
		Update_GetInternetFile = "err"
		Exit Function
	End If

	If xmlHttp.readystate = 4 then 
	'if xmlHttp.status=200 Then
		Update_GetInternetFile = xmlhttp.Responsebody
	'end if 
	Else 
		Update_GetInternetFile = "err"
	End If
	Set xmlHttp = Nothing

End Function

Sub Default_NavItem

	Dim NewUrl
	NewUrl = DEF_BBS_HomeUrl
	If Left(NewUrl,3) = "../" or Left(NewUrl,3) = "..\" Then NewUrl = Mid(NewUrl,4)
	%>
	<script language=javascript>
	function sss(obj)
	{
		if(obj.style.display == "none")
		{
			obj.style.display = "block";
		}
		else
		{
			obj.style.display = "none";
		}
	}
	</script>
	<div class="nav_itemlist" id="nav_itemlist0">
	</div>
	<div class="nav_itemlist" id="nav_itemlist1">
		<div class="item"><a href=<%=NewUrl%>Default.asp?action=info target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist1_default"><span>管理中心首页</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteSetup.asp target="mainFrame" onclick="nav_sel(this);"><span>全局参数设置</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/UploadSetup.asp target="mainFrame" onclick="nav_sel(this);"><span>上传参数设置</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/UbbcodeSetup.asp target="mainFrame" onclick="nav_sel(this);"><span>内容编码参数设置</span></a></div>
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteInfo.asp?action=Side target="mainFrame" onclick="nav_sel(this);"><span>侧栏设置</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/IPManage.asp target="mainFrame" onclick="nav_sel(this);" title="允许屏蔽IP段或某个IP地址"><span>IP地址屏蔽</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteLink.asp target="mainFrame" onclick="nav_sel(this);"><span>友情论坛管理</span></a></div>
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		<div class="item"><a href=<%=NewUrl%>User/SendMailList.asp target="mainFrame" onclick="nav_sel(this);"><span>邮件发送及群发</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/SendGroupMessage.asp target="mainFrame" onclick="nav_sel(this);"><span>论坛短消息群发</span></a></div>
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		
		
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteEditFileContent.asp?file=-1 target="mainFrame" onclick="nav_sel(this);"><span>编辑用户注册协议</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteEditFileContent.asp?file=-3 target="mainFrame" onclick="nav_sel(this);"><span>编辑联系我们信息</span></a></div>
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteInfo.asp target="mainFrame" onclick="nav_sel(this);"><span>站点信息及网站修复</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/Space.asp target="mainFrame" onclick="nav_sel(this);" title="查看数据库，上传文件及论坛总占用空间情况，需要时间可能较长"><span>查看空间占用情况</span></a></div>
		<div class="item"><a href=<%=NewUrl%>update.asp?checkversion=checkversion&sure=1&submitflag=1 target="mainFrame" onclick="nav_sel(this);"><span>检测是否有版本更新</span></a></div>
		<div class="item"><a href=<%=NewUrl%>update.asp?sure=1 target="mainFrame" onclick="nav_sel(this);"><span>导出扩展参数</span></a></div>
		<div class="item"><a href=<%=NewUrl%>update.asp?submitflag=1&sure=1 target="mainFrame" onclick="nav_sel(this);"><span>配置扩展参数</span></a></div>
		<div class="item"><a href=<%=NewUrl%>update.asp?sure=1&checkversion=updateversion&submitflag=1 target="mainFrame" onclick="nav_sel(this);"><span>立即更新补丁</span></a></div>
	</div>
	<div class="nav_itemlist" id="nav_itemlist2" style="display:none;">
		<div class="item"><a href=<%=NewUrl%>ForumCategory/ForumCategoryManage.asp target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist2_default"><span>论坛分类管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>ForumCategory/ForumCategoryManage.asp?action=join target="mainFrame" onclick="nav_sel(this);"><span>添加论坛分类</span></a></div>
	</div>
	<div class="nav_itemlist" id="nav_itemlist3" style="display:none;">
		<div class="item"><a href=<%=NewUrl%>ForumBoard/ForumBoardManage.asp target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist3_default"><span>论坛版面管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>ForumBoard/ForumBoardJoin.asp target="mainFrame" onclick="nav_sel(this);"><span>添加论坛版面</span></a></div>
		<div class="item"><a href=<%=NewUrl%>ForumBoard/ForumBoardAssort.asp target="mainFrame" onclick="nav_sel(this);"><span>论坛版面专区管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>ForumBoard/MakeBoardList.asp target="mainFrame" onclick="nav_sel(this);"><span>重做论坛列表及修复</span></a></div>
		<div class="item"><a href=<%=NewUrl%>ForumBoard/RepairYesterdayAnc.asp target="mainFrame" onclick="nav_sel(this);"><span>重新计算昨日发帖量</span></a></div>
	</div>
	<div class="nav_itemlist" id="nav_itemlist4" style="display:none;">
		<div class="item"><a href=<%=NewUrl%>User/UserManage.asp target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist4_default" title="论坛所有用户列表，提供强制修改及强制指定权限分配"><span>论坛用户管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/UserSpecial.asp target="mainFrame" onclick="nav_sel(this);" title="特殊用户包括版主，受屏蔽用户或待激活用户等等，详细请点击进入管理"><span>特殊用户管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/UserSetup.asp target="mainFrame" onclick="nav_sel(this);" title="设定新用户注册的选项"><span>用户注册参数设置</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/UserJoin.asp target="mainFrame" onclick="nav_sel(this);" title="强制添加一个新用户，即使前台关闭了注册功能"><span>添加新用户</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/DeleteForbidIPandUser.asp target="mainFrame" onclick="nav_sel(this);"  title="某些屏蔽ＩＰ地址及屏蔽的用户或<%=DEF_PointsName(5)%>有到期期限，每天请手工执行一次，以作清除"><span>解除到期特殊用户及IP</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/ClearOnlineUser.asp target="mainFrame" onclick="nav_sel(this);" title=将所有在线用户暂时踢下线><span>清理在线用户/用户排名</span></a></div>
		
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteEditFileContent.asp?file=-1 target="mainFrame" onclick="nav_sel(this);"><span>用户注册协议</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteEditFileContent.asp?file=-３ target="mainFrame" onclick="nav_sel(this);"><span>论坛联系方式设定</span></a></div>
		
		<div class="item"><a href=<%=NewUrl%>User/UserSetup.asp#medal target="mainFrame" onclick="nav_sel(this);" title="用户<%=DEF_PointsName(9)%>名称及信息设置"><span>徽章设置</span></a></div>
		<div class="item"><a href=<%=NewUrl%>User/UserSetup.asp?action=medal target="mainFrame" onclick="nav_sel(this);" title=""><span>徽章添加或删除</span></a></div>
	</div>
	
	<div class="nav_itemlist" id="nav_itemlist5" style="display:none;">
		<div class="item"><a href=<%=NewUrl%>Database/ExecuteString.asp target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist5_default"><span>直接执行SQL语句</span></a></div>
		<%If DEF_UsedDataBase = 0 Then%>
		<div class="item"><a href=<%=NewUrl%>Database/FullTextManage.asp target="mainFrame" onclick="nav_sel(this);"><span>全文检索及数据库管理</span></a></div>
		<%End If%>
		<%If DEF_UsedDataBase = 1 Then%>
		<div class="item"><a href=<%=NewUrl%>Database/BackupDatabase.asp target="mainFrame" onclick="nav_sel(this);"><span>数据库备份及压缩</span></a></div>
		<%End If%>
	</div>
	<div class="nav_itemlist" id="nav_itemlist6" style="display:none;">
		<div class="item"><a href=<%=NewUrl%>SiteManage/TempletManage.asp target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist6_default"><span>论坛模板管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteEditFile.asp target="mainFrame" onclick="nav_sel(this);"><span>在线编辑及风格设定</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/DefineStyleParameter.asp?action=extentskin_manage target="mainFrame" onclick="nav_sel(this);"><span>扩展风格设定</span></a></div></a></div>
	</div>
	<div class="nav_itemlist" id="nav_itemlist7" style="display:none;">
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteLink.asp?SiteLink_Flag=10 target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist7_default"><span>帖间广告管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteInfo.asp?action=admanage target="mainFrame" onclick="nav_sel(this);"><span>综合广告栏位管理</span></a></div>
	</div>
	
	<div class="nav_itemlist" id="nav_itemlist8" style="display:none;">
		<div class="item"><a href=<%=NewUrl%>BlockUpdate/BlockUpdate.asp target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist8_default"><span>批量修复论坛数据</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/DeleteAllTopAnnounce.asp target="mainFrame" onclick="nav_sel(this);"><span>清除总固顶帖(带修复)</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/RepairSite.asp target="mainFrame" onclick="nav_sel(this);"><span>上传路径/用户及附件修复</span></a></div>
		<div class="item"><a href=<%=NewUrl%>BlockUpdate/BlockUpdate.asp?action=blockdelete target="mainFrame" onclick="nav_sel(this);"><span>论坛数据批量删除</span></a></div>
		
		<%
		If application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 1 or application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = "" Then
		%>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteOpenClose.asp?Flag=close target="mainFrame" onclick="nav_sel(this);"><span>暂停论坛访问</span></a></div>
		<%
		Else
		%>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteOpenClose.asp?Flag=open target="mainFrame" onclick="nav_sel(this);"><span>开启论坛访问</span></a></div>
		<%
		End If%>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteReset.asp?Flag=open target="mainFrame" onclick="nav_sel(this);"><span>重新启动论坛</span></a></div>
		
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteInfo.asp?action=MoreSV target="mainFrame" onclick="nav_sel(this);"><span>论坛扩展服务</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/SiteInfo.asp?action=SiteMap target="mainFrame" onclick="nav_sel(this);"><span>SiteMap生成和更新</span></a></div>
		
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/ForumLog.asp target="mainFrame" onclick="nav_sel(this);"><span>论坛日志管理</span></a></div>
		<div class="item"><a href=<%=NewUrl%>SiteManage/ForumLog.asp?clear=yes target="mainFrame" onclick="nav_sel(this);"><span>清除两天前的论坛日志</span></a></div>
		
		<div class="item">
			<a href=javascript:;><div class=nav_sepline></div></a>
		</div>
		
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>Search/UploadList.asp target="_blank" onclick="nav_sel(this);"><span>上传附件管理</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>User/MyInfoBox.asp?AllPrinting=Yesing target="_blank" onclick="nav_sel(this);"><span>短消息管理</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>User/LookUserInfo.asp?Evol=bag target="_blank" onclick="nav_sel(this);"><span>收藏帖子管理</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>User/SendMessage.asp?pub=1 target="_blank" onclick="nav_sel(this);"><span>发布公告</span></a></div>
	</div>
	
	
	
	<div class="nav_itemlist" id="nav_itemlist9" style="display:none;">
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsclass&list=1 target="mainFrame" onclick="nav_sel(this);" id="nav_itemlist9_default"><span>分类管理</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsclass target="mainFrame" onclick="nav_sel(this);"><span>分类添加</span></a></div>
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsarticle target="mainFrame" onclick="nav_sel(this);"><span>文章添加</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsmanage target="mainFrame" onclick="nav_sel(this);"><span>文章管理</span></a></div>
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=setchannel target="mainFrame" onclick="nav_sel(this);"><span>设置首页栏目内容</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=editfile&form_fileid=0 target="mainFrame" onclick="nav_sel(this);"><span>编辑首页图片新闻</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=editfile&form_fileid=1 target="mainFrame" onclick="nav_sel(this);"><span>自定义网站底部信息</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=editfile&form_fileid=2 target="mainFrame" onclick="nav_sel(this);"><span>CSS样式表</span></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=editfile&form_fileid=99 target="mainFrame" onclick="nav_sel(this);"><span>修改默认LOGO</span></a></div>
		<div class="item"><a href=javascript:;><div class=nav_sepline></div></a></div>
		<div class="item"><a href=<%=DEF_BBS_HomeUrl%>article/center.asp?action=updatecache target="mainFrame" onclick="nav_sel(this);"><span>立即更新系统缓存</span></a></div>
	</div>
	<script>
	var nav_curassort = 1;
	nav_sel($id("nav_itemlist1_default"));
	</script>
<%

End Sub

Function CheckObjInstalled2(strClassString)

	On Error Resume Next
	Dim Temp
	Err = 0
	Dim TmpObj
	Set TmpObj = CreateObject(strClassString)
	Temp = Err
	If Temp = 0 Then
		CheckObjInstalled2 = True
		GBL_CHK_TempStr = "<font color=green class=greenfont>√</font>"
	ElseIf Temp = -2147221005 Then
		GBL_CHK_TempStr = "<font color=red class=redfont>组件未安装</font>"
		CheckObjInstalled2 = False
	ElseIf Temp = -2147221477 Then
		GBL_CHK_TempStr = "<font color=green class=greenfont>√支持此组件</font>"
		CheckObjInstalled2 = True
	ElseIf Temp = 1 Then
		GBL_CHK_TempStr = "<font color=red class=redfont>×未知的错误，组件可能未正确安装</font>"
		CheckObjInstalled2 = False
	End If
	Err.Clear
	dim ver
	ver = TmpObj.version
	if err Then
		err.clear
	else
		Response.Write " version:" & ver
	end if
	Set TmpObj = Nothing
	Err = 0

End Function

Function CheckObjInstalled(strClassString)

	On Error Resume Next
	Dim Temp
	Err = 0
	Dim TmpObj
	Set TmpObj = Server.CreateObject(strClassString)
	Temp = Err
	If Temp = 0 Then
		CheckObjInstalled = True
		GBL_CHK_TempStr = "<font color=green class=greenfont>√</font>"
	ElseIf Temp = -2147221005 Then
		GBL_CHK_TempStr = "<font color=red class=redfont>组件未安装</font>"
		CheckObjInstalled = False
	ElseIf Temp = -2147221477 Then
		GBL_CHK_TempStr = "<font color=green class=greenfont>√支持此组件</font>"
		CheckObjInstalled = True
	ElseIf Temp = 1 Then
		GBL_CHK_TempStr = "<font color=red>×未知的错误，组件可能未正确安装</font>"
		CheckObjInstalled = False
	End If
	Err.Clear
	dim ver
	ver = TmpObj.version
	if err Then
		err.clear
	else
		Response.Write strClassString & " version " & ver
	end if
	Set TmpObj = Nothing
	Err = 0

End Function
%>