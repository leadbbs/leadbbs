<%
class Plug_MusicBar_Music_class

public Sub Plug_MusicBar_Music

%>
<html>
<head>
<link rel="stylesheet" type="text/css" href="<%=DEF_BBS_homeUrl%>inc/js/jplayer/css/blue.css<%=DEF_Jer%>" />
<script src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.js<%=DEF_Jer%>" type="text/javascript"></script>
<script src="<%=DEF_BBS_HomeUrl%>inc/js/common.js<%=DEF_Jer%>" type="text/javascript"></script>
<script src="<%=DEF_BBS_HomeUrl%>inc/js/jplayer/js/jquery.jplayer.js<%=DEF_Jer%>" type="text/javascript"></script>
<script src="<%=DEF_BBS_HomeUrl%>inc/js/jplayer/js/jplayer.playlist.min.js<%=DEF_Jer%>" type="text/javascript"></script>
<style>
body{padding:0px;margin:0px;}
*{font-size:9pt !important;}
.jp-audio{width:640px !important;}
.jp-current-time{margin-left:170px;font-style:normal !important;font-size:8pt;top:-12px;position:relative;}
.jp-duration{margin-left:1px;float:left !important;font-style:normal !important;font-size:8pt;top:-12px;position:relative;}
.jp-playlist{max-height:320px;overflow-y:auto;
height: expression((this.scrollHeight>320)?320:this.scrollHeight-22+'px');

}
</style>
</head>
<body>
<div id="jquery_jplayer_1" class="jp-jplayer"></div>

		<div id="jp_container_1" class="jp-audio">
			<div class="jp-type-playlist">
				<div class="jp-gui jp-interface">
					<ul class="jp-controls">
						<li><a href="javascript:;" class="jp-previous" tabindex="1">previous</a></li>
						<li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
						<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
						<li><a href="javascript:;" class="jp-next" tabindex="1">next</a></li>
						<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>
						<li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>
						<li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>
						<li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>
					</ul>
					<div class="jp-progress">
						<div class="jp-seek-bar">
							<div class="jp-play-bar"></div>

						</div>
					</div>
					<div class="jp-volume-bar">
						<div class="jp-volume-bar-value"></div>
					</div>
					<div class="jp-current-time"></div>
					<div class="jp-duration"></div>
					<ul class="jp-toggles">
						<li><a href="javascript:;" class="jp-shuffle" tabindex="1" title="shuffle">shuffle</a></li>
						<li><a href="javascript:;" class="jp-shuffle-off" tabindex="1" title="shuffle off">shuffle off</a></li>
						<li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>
						<li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>
					</ul>
				</div>
				<div class="jp-playlist">
					<ul>
						<li></li>
					</ul>
				</div>
				<div class="jp-no-solution">
					<span>Update Required</span>
					To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
				</div>
			</div>
		</div>

<%
if CheckSupervisorNameOnly = 1 then%>
<br><a href=default.asp?file=edit target=_blank>您是管理员，点此编辑播放列表</a>
<%end if%>
<script>
var playlist = [];

function mkList(url,txt,a,b)
{
	playlist.push({
			title:txt,
			mp3:url
		});
}

</script>
<script src="bglist.js<%=DEF_Jer%>" type="text/javascript"></script>
			<div id="jplayer_inspector_1"></div>

<script type="text/javascript">
$(document).ready(function(){

	new jPlayerPlaylist({
		jPlayer: "#jquery_jplayer_1",
		cssSelectorAncestor: "#jp_container_1"
	}, playlist, {
		swfPath: "<%=DEF_BBS_HomeUrl%>inc/js/jplayer/js",
		supplied: "oga, mp3",
		wmode: "window",
		smoothPlayBar: true,
		keyEnabled: true
	});
});
</script>

</body>
</html>

<%End Sub

public Sub Plug_MusicBar_Edit

	Dim Master
	Dim EditMod,MyStr
	EditMod = Request("EditMod")
	MyStr = "<table width=600><tr><td><b>在线编辑歌曲列表文件bglist.js</b>--<font color=red>注意事项</font></td></tr>"
	If EditMod = "0" Then
		MyStr = MyStr&"<tr><td><li>格式 mkList('音乐文件路径','音乐节目名称','字幕地址','是否播放(f为不播放,播放留空)');<li>比如 mkList('hi/LeadBBS_H1.mp3','Welcome to LeadBBS.','','');</td></tr>"
	Else
		EditMod = "1"
		MyStr = MyStr&"<tr><td><ul><li>歌曲标题或歌曲地址留空，将从列表中删除;<li>排序数字必须介于编号的最小最大值之间,重复或者超出将从列表中删除;</li><li>只支持Mp3格式文件，其它格式请先转换。</li></ul></td></tr>"
	End If
	MyStr = MyStr&"<tr><td><input type=button onclick=""location='default.asp?file=edit&editmod=0'"" value=""文本模式"" class=fmbtn>&nbsp;&nbsp;<input type=button onclick=""location='default.asp?file=edit&editmod=1'"" value=""列表模式"" class=fmbtn></td></tr></table>"
	
	InitDatabase
	BBS_SiteHead DEF_SiteNameString &" - 音乐播放",GBL_board_ID," 论坛音乐盒"
	
	%>	
	<div class="area">
	<%
	If CheckSupervisorNameOnly = 1 and GBL_UserID > 0 Then
		Master = True
	Else
		Master = False
	End If
	CloseDatabase
	
	Global_TableHead
	%>
	<table cellpadding=3 cellspacing=1 style="margin-top:35px;" align=center width=100% class=TBone>
	<tr class=TBHead height=24>
		<td align=center><b><font class=HeadFont><a href=default.asp>官方版LeadBBS音乐播放插件</a> 管理中心</font><b></td>
	</tr>
	<%
	If GBL_CHK_User = "" or Master = False Then
		Response.Write "<tr class=TBBG1><td><table cellpadding=3 cellspacing=4><tr><td>产生错误的原因可能是：<br><br><li>你不是管理员，无权进入！</li><li>如果你是管理员，请以管理员身份<a href='" & DEF_BBS_HomeUrl & "User/Login.asp?Relogin=Yes&u=" & urlencode(Request.Servervariables("SCRIPT_NAME") & "?" & Request.QueryString) & "'><font class=NavColor>重登录</font></a>！</li></td></tr></table></td></tr></table>"
	Else
		%>
		<tr class=TBBG1><td align=center>
		<br>
		<%
		DisplayEditFileContent "bglist.js",MyStr,"edit",EditMod
		%>
		</td></tr>
		<%
	End If
	%>
	</table>
	<%
	Global_TableBottom
	%>
	
	</div>
	<%
	SiteBottom
	If GBL_ShowBottomSure = 0 Then GBL_SiteBottomString = ""
	Response.Write GBL_SiteBottomString

End Sub

'FileName 相对路径
'TemStr 编辑注释
'FilePar 隐藏传递参数
private Sub DisplayEditFileContent(FileName,TmpStr,FilePar,eMod)

	'If DEF_FSOString = "" Then
	'	Response.Write "<p><br><font color=red class=redfont>论坛已设置成不支持在线编辑文件功能!</font></p>" & VbCrLf
	'	Exit Sub
	'End If
	Dim fileContent

	If Request.Form("SubmitFlag") = "" Then
		FileContent = ADODB_LoadFile(FileName)
		If GBL_CHK_TempStr <> "" Then
			Response.Write "<p>" & GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
			Exit Sub
		End If
	Else
		If eMod="0" Then
			fileContent = Request.Form("fileContent")
		Else
			Dim i,mI,mName,mLink,mF,mO
			mI=Request.Form("mName").count
			For i=1 to mI
				fileContent=fileContent&"//"&i&"//"&vbcrlf
			Next
			For i=1 to mI
				If request.Form("mName")(i)<>"" And request.Form("mLink")(i)<>"" Then
					fileContent=Replace(fileContent,"//"&request.Form("mO")(i)&"//","mkList('"&request.Form("mLink")(i)&"','"&request.Form("mName")(i)&"','','"&cht(request.Form("mF"&i))&"');")
				Else
					fileContent=Replace(fileContent,","&request.Form("mO")(i)&","&vbcrlf,"")
				End If
			Next
		End If
		Dim TempContent
		TempContent = Lcase(fileContent)
		If inStr(TempContent,"<%") or inStr(TempContent,"include") or inStr(TempContent,"server") Then
			Response.Write "<p><br><font color=red class=redfont>内容中不能含有<%，include，Server等字符!</font></p>" & VbCrLf
			Exit Sub
		End If

		ADODB_SaveToFile fileContent,FileName
		If GBL_CHK_TempStr <> "" Then
			Response.Write "<p>" & GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
			Exit Sub
		Else
			Response.Write "<p><font color=green class=greenfont><b>成功更新文件内容！</b></font></p>" & VbCrLf
		End If
	End If
	%>
	<form action=Default.asp method=post>
		<%=TmpStr%><p>
		<input type=hidden value=<%=FilePar%> name=file>
		<input type=hidden value=yes name=SubmitFlag>
		<input type=hidden value=<%=eMod%> name="EditMod">
		<%If eMod = "0" Then%>
		<textarea name="fileContent" cols="96" rows="20" class=fmtxtra><%If fileContent <> "" Then Response.Write VbCrLf & server.htmlEncode(fileContent)%></textarea></p>
		<%Else%>
		<style>
		#list td{ text-align:center;border:1px dashed #000000; height:24px}
		.txt{ border:1px solid #000000; text-align:center; width:220px}
		</style>
		<table width=600 id="list"><tr><td width=30>编号</td><td width=240>歌曲标题</td><td width=240>歌曲地址</td><td width=60>是否播放</td><td width=30>排序</td></tr><%
		Dim objRegExp,Matches,j
		Set objRegExp=New RegExp
		objRegExp.IgnoreCase =True
		objRegExp.Global=True
		objRegExp.Pattern="mkList\(\'(.*?)\',\'(.*?)\',\'\',\'(.*?)\'\);"
		Set Matches = objRegExp.Execute(fileContent)
		For j = 0 to Matches.Count - 1
			Response.Write "<tr><td>"&j+1&"</td><td><input name=mName type=text class=txt value="""&Matches(j).SubMatches(1)&"""></td><td><input name=mLink type=text class=txt value="""&Matches(j).SubMatches(0)&"""></td><td><input name=mF"&j+1&" type=checkbox value=""t"" "&Chf(Matches(j).SubMatches(2))&"></td><td><input name=mO type=text class=txt style=""width:20px"" value="""&j+1&"""></td></tr>"&vbcrlf
		Next				
		%></table><div align="left" style="margin-left:70px"><input type="button" onclick="AddRow()" value="增加一行" class=fmbtn></div>
		<Script Language="Javascript">
		function AddRow()
		{
		var i =list.rows.length;
		var newTr = list.insertRow();
		var newTd0 = newTr.insertCell();
		var newTd1 = newTr.insertCell();
		var newTd2 = newTr.insertCell();
		var newTd3 = newTr.insertCell();
		var newTd4 = newTr.insertCell();
		newTd0.innerHTML = i; 
		newTd1.innerHTML= "<input name=mName type=text class=txt value=\"\">";
		newTd2.innerHTML= "<input name=mLink type=text class=txt value=\"\">";
		newTd3.innerHTML= "<input name=mF"+i+" type=checkbox value=\"t\" checked>";
		newTd4.innerHTML= "<input name=mO type=text class=txt style=\"width:20px\" value=\""+i+"\">";
		}
		</script>
		<%End If%>
		<input type="submit" name="save" value="提交编辑" class=fmbtn>
		<input type="reset" name="Reset" value="取消" class=fmbtn>
		</form>
	<%

End Sub

private Function cht(str)

	If str="t" then
		cht=""
	Else
		cht="f"
	End If

End Function

private Function chf(str)

	If str="" then
		chf="checked"
	Else
		chf=""
	End If

End Function

private Function ADODB_LoadFile(ByVal File)

	On Error Resume Next
	Dim objStream,FSFlag,fs,WriteFile
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If

	If FSFlag = 1 Then
		Set WriteFile = fs.OpenTextFile(Server.MapPath(File),1,True)
		If Err Then
			GBL_CHK_TempStr = "<br>读取文件失败：" & err.description & "<br>其它可能：确定是否对此文件有读取权限."
			err.Clear
			Set Fs = Nothing
			Exit Function
		End If
		If Not WriteFile.AtEndOfStream Then
			ADODB_LoadFile = WriteFile.ReadAll
			If Err Then
				GBL_CHK_TempStr = "<br>读取文件失败：" & err.description & "<br>其它可能：确定是否对此文件有读取权限."
				err.Clear
				Set Fs = Nothing
				Exit Function
			End If
		End If
		WriteFile.Close
		Set Fs = Nothing
	Else
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err.Number=-2147221005 Then 
			GBL_CHK_TempStr = "<div align='center'>您的主机不支持ADODB.Stream，无法完成操作，请手工进行</div>"
			Err.Clear
			Set objStream = Nothing
			Exit Function
		End If
		With objStream
			.Type = 2
			.Mode = 3
			.Open
			.LoadFromFile Server.MapPath(File)
			.Charset = "gb2312"
			.Position = 2
			ADODB_LoadFile = .ReadText
			.Close
		End With
		Set objStream = Nothing
	End If
	If Err Then
		GBL_CHK_TempStr = "<br>错误信息：" & err.description & "<br>其它可能：确定是否对此文件有读取权限."
		err.Clear
		Set Fs = Nothing
		Exit Function
	End If

End Function

'存储内容到文件
private Sub ADODB_SaveToFile(ByVal strBody,ByVal File)

	On Error Resume Next
	Dim objStream,FSFlag,fs,WriteFile
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If
	
	If FSFlag = 1 Then
		Set WriteFile = fs.CreateTextFile(Server.MapPath(File),True)
		WriteFile.Write strBody
		WriteFile.Close
		Set Fs = Nothing
	Else
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err.Number=-2147221005 Then 
			GBL_CHK_TempStr = "<div align='center'>您的主机不支持ADODB.Stream，无法完成操作，请手工进行</div>"
			Err.Clear
			Set objStream = Nothing
			Exit Sub
		End If
		With objStream
			.Type = 2
			.Open
			.Charset = "gb2312"
			.Position = objStream.Size
			.WriteText = strBody
			.SaveToFile Server.MapPath(File),2
			.Close
		End With
		Set objStream = Nothing
	End If
	If Err Then
		GBL_CHK_TempStr = "<br>错误信息：" & err.description & "<br>其它可能：确定是否对此文件有写入权限."
		err.Clear
		Set Fs = Nothing
		Exit Sub
	End If

End Sub

end class%>