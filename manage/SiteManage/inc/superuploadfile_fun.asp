<!--#include file="../../../a/inc/upload1_fun.asp"-->
<!--#include file="../../../inc/limit_fun.asp"-->
<%
Class super_uploadfile

	private p_filename,p_filepath
	private Form_UpFlag,Form_UpClass
	private p_allowfiletype,p_fileinfo,p_boardid,p_boardname,p_logo,p_boardlimit
	
	Private Sub Class_Initialize
	
		p_allowfiletype = "|.png|.jpeg|.jpg|.jpe|.gif|"
		If dontRequestFormFlag = "" Then
			Form_UpFlag = 0
		Else
			Form_UpFlag = 1
			Server.ScriptTimeOut=3000
			set Form_UpClass=new upload_Class
			Form_UpClass.ProgressID = Request.QueryString("Upload_ID")
			Form_UpClass.GetUpFile
		end if
		class_main()
		If Form_UpFlag = 1 Then Set Form_UpClass = Nothing
	
	End Sub
	
	private sub class_main
	
		p_boardid = toNum(GetFormData("p_boardid"),0)
		p_logo = GetFormData("p_logo")
		if p_logo <> "1" then p_logo = ""
		if p_boardid > 0 then
			p_boardname = class_getboardinfo(p_boardid)
			if p_boardid <= 0 then
				Call Global_ErrMsg("版面参数错误.")
				exit sub
			end if
			if p_logo = "1" then
				p_fileinfo = "修改版面<u>" & p_boardname & "</u>(编号" & p_boardid & ")LOGO图片，必须是png图片"
				p_filepath = "images/board/"
				p_filename = "b_" & p_boardid & ".png"
			else
				p_fileinfo = "修改版面<u>" & p_boardname & "</u>(编号" & p_boardid & ")标志图片，必须是png图片"
				p_filepath = "images/board/"
				p_filename = "s_" & p_boardid & ".png"
			end if
		else
			p_fileinfo = htmlencode(GetFormData("p_fileinfo"))
			p_filepath = replace(class_filter(GetFormData("p_filepath")),".","")
			if left(p_filepath,1) = "/" then p_filepath = mid(p_filepath,2)
			'必须图片目录下上传
			if lcase(left(p_filepath,7)) <> "images/" and lcase(left(p_filepath,len("article/images/"))) <> "article/images/" then
				Call Global_ErrMsg("参数错误2.")
				exit sub
			end if

			Dim TDir,FS
			Set fs = Server.CreateObject(DEF_FSOString)
			TDir = Server.MapPath(DEF_BBS_HomeUrl & p_filepath)
			If Not FS.FolderExists(TDir) then
				Call Global_ErrMsg("文件存放目录错误.")
				exit sub
			End If
			
			p_filename = replace(class_filter(GetFormData("p_filename")),"/","")
			if Reg_Replace(p_filename,"([a-z0-9\.\_])","") <> "" then
				Call Global_ErrMsg("参数错误3.")
				exit sub
			end if
			if len(p_filename) - len(Replace(p_filename,".","")) <> 1 then
				Call Global_ErrMsg("参数错误4.")
				exit sub
			end if
			dim ext,tmp,fm
			tmp = split(p_filename,".")
			fm = tmp(0)
			ext = lcase(tmp(1))
			if ext <> "jpg" and ext <> "png" and ext <> "gif" then
				Call Global_ErrMsg("参数错误5.")
				exit sub
			end if
			p_filename = fm & "." & ext
			
			Set fs = Server.CreateObject(DEF_FSOString)
			TDir = Server.MapPath(DEF_BBS_HomeUrl & p_filepath & p_filename)
			If Not FS.FileExists(TDir) then
				Call Global_ErrMsg("目标文件不存在,禁止修改.")
				exit sub
			End If
		end if
		
		if len(p_filename) - len(replace(p_filename,".","")) > 1 or p_filename = "" or p_filepath = "" then
			Call Global_ErrMsg("参数错误.")
			exit sub
		end if
		
		if GetFormData("submitflag") <> "yes" then
			class_form()
		else
			class_save()
		end if
	
	end sub
	
	private sub class_form
	%>
	<p class="title"><b><%=p_fileinfo%></b></p>
	<p>上传替换文件：<%=htmlencode(p_filepath&p_filename)%>
	</p>
	<form action="siteinfo.asp?dontRequestFormFlag=1&amp;action=upload" method="post" name="LeadBBSFm" id="LeadBBSFm" enctype="multipart/form-data" onsubmit="submit_disable(this);">
		<input name="submitflag" type="hidden" value="yes">
		<input name="p_filepath" type="hidden" value="<%=htmlencode(p_filepath)%>">
		<input name="p_filename" type="hidden" value="<%=htmlencode(p_filename)%>">
		<input name="p_boardid" type="hidden" value="<%=p_boardid%>">
		<input name="p_logo" type="hidden" value="<%=p_logo%>">
		<div><input type="file" id="file" size="11" name="p_upfile" class="fminpt uninit_upload">
		</div>
		<div class="clear"></div>
		<br>
		<input name="submit" id="submit" type="submit" value="开始上传" class="fmbtn btn_3">
	</form>
	<%if p_boardid > 0 and p_logo = "1" then%>
	<br>
	<p>
	<a href="siteinfo.asp?action=upload&submitflag=yes&p_boardid=<%=p_boardid%>&p_logo=1&p_del=1"><b>点此删除此LOGO文件</b></a>
	</p>
	<%end if%>
	<script>init_uploadform();</script>
	<hr class="splitline">
	<b>文件要求：</b>
	<ul>
	<li>必须是图片文件</li>
	<li>必须小于512K</li>
	<li>文件扩展名和格式务必同原文件相同</li>
	</ul>
	<hr class="splitline">
	<p>
	<b>目前图片：</b>
	</p>
	<hr class="splitline">
	<p><%Randomize%>
	<img src="<%=DEF_BBS_HomeUrl&htmlencode(p_filepath&p_filename)%>?<%=rnd*100%>">
	</p>
	<%
	end sub
	
	private sub class_save

		dim val
		val = 1
		if GetFormData("p_del") = "1" then
			if p_boardid > 0 and p_logo = "1" then
				DeleteFiles(Server.MapPath(DEF_BBS_HomeUrl & p_filepath & p_filename))
				val = 0
				Response.Write "<b>成功删除文件。</b>"
			end if
		end if

		if val = 1 then
			dim file
			set file = Form_UpClass.file("p_upfile")
	
			Dim FileType,Tmp,FileSize
			FileType = LCase(file.FileType)
			FileSize = file.FileSize
			Tmp = InStr(FileType,"/")
			If Tmp > 0 Then
				Tmp = Left(FileType,Tmp-1)
			Else
				Tmp = FileType
			End If
			If Tmp = "image" and (inStr(FileType,"pjpeg") or inStr(FileType,"png") or inStr(FileType,"jpeg") or inStr(FileType,"gif")) Then
			Else
				Call Global_ErrMsg("必须是jpg,gif或png图片。")
				set file = nothing
				exit sub
			End If
			If FileSize > 524288 Then
				Call Global_ErrMsg("图片过大，必须小于512K。")
			end if
			file.saveas Server.MapPath(DEF_BBS_HomeUrl & p_filepath & p_filename)
			Set file = Nothing
			Response.Write "<b>成功完成上传。</b>"
		end if

		dim old_p_BoardLimit
		old_p_BoardLimit = p_BoardLimit
		p_BoardLimit = SetBinarybit(p_BoardLimit,25,val)
		if p_boardid > 0 and p_logo = "" then
			call ldexecute("update leadbbs_boards set BoardImgUrl='" & replace(p_filepath & p_filename,"'","''") & "' where boardid=" & p_boardid,1)
		elseif p_boardid > 0 and p_logo = "1" and p_BoardLimit <> old_p_BoardLimit then
			call ldexecute("update leadbbs_boards set BoardLimit=" & p_BoardLimit & " where boardid=" & p_boardid,1)
		end if
		Call ReloadBoardInfo(p_boardid)

	end sub
	
	private Function GetFormData(name)

		If Form_UpFlag = 0 Then
			GetFormData = Request.Form(name)
		Else
			GetFormData = Form_UpClass.form(name)
		End If
		if GetFormData = "" then
			GetFormData = request.querystring(name)
		end if

	End Function
	
	private Function class_filter(s)
	
		class_filter = left(replace(replace(replace(replace(replace(replace(trim(s),"\","/")," ",""),"$",""),"?",""),"<",""),"%",""),100)
	
	end Function
	
	private function class_getboardinfo(id)
	
		dim sql,rs
		sql = sql_select("select boardname,boardlimit from leadbbs_boards where BoardID=" & id,1)
		set rs = ldexecute(sql,0)
		if rs.eof then
			p_boardid = 0
			class_getboardinfo = ""
			p_boardlimit = 0
		else
			class_getboardinfo = rs(0)
			p_boardlimit = rs(1)
		end if
		rs.close
		set rs = nothing
	
	end function

	private Function DeleteFiles(path)
	
		If DEF_FSOString = "" Then Exit Function
		on error resume next
		Dim fs
		Set fs = Server.CreateObject(DEF_FSOString)
		If err <> 0 Then
			Err.Clear
			Response.Write "<p>服务器不支持FSO，硬盘文件未删除．</p>"
			Exit Function
		End If
		If fs.FileExists(path) Then
			fs.DeleteFile path,True
			DeleteFiles = 1
		Else
			DeleteFiles = 0
		End If
		Set fs = Nothing
	
	End Function
	
end class
%>	