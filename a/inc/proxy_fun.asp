<%
Class Proxy_Class

Public Sub GetBody(url)

	url = filterUrlstr(Left(url,5000))
	If url = "" Then Exit Sub
	if left(url,1) = "/" or left(url,1) = "\" then
		url = LD_GetUrl(0) & url
	end if
	
	Dim xmlHttp
	Set xmlHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
	xmlHttp.setTimeouts 5000,5000,5000,15000
	xmlHttp.setOption 2, 13056
	xmlHttp.open "GET", url, False, "", "" 
	
	dim domain
	domain = replace(replace(replace(url,"http://",""),"https://",""),"\","/")
	if inStr(domain,"/") then domain = mid(domain,1,inStr(domain,"/")-1)
	if inStr(domain,":") then domain = mid(refer,1,inStr(domain,":")-1)

	xmlhttp.setRequestHeader "referer","http://" & domain & "/"
	
	on error resume next
	xmlHttp.send()
	If Err Then
		Exit Sub
	End If

	dim bin : bin = 0
	if request.querystring("bin") = "1" then bin = 1
	If xmlHttp.readystate = 4 then 
	'if xmlHttp.status=200 Then
		'Response.Write xmlHttp.ResponseText
		if bin = 1 then
			'dim type : type = trim(left(request.querystring("type"),50))
			'if type & "" <> "" then Response.ContentType = server.htmlencode(type)
			Response.binaryWrite xmlhttp.Responsebody
		else
			Response.Write BytesToBstr(xmlhttp.Responsebody)
		end if
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
	.Charset = "GB2312"
	
	if request.querystring("utf8") = "1" then
		Response.Charset="UTF-8"
		response.codepage = 65001
		.Charset = "UTF-8"
	end if
	BytesToBstr = .ReadText
	.Close
	end with
	set objstream = nothing

End Function


private function filterUrlstr(str)

	filterUrlstr = replace(replace(replace(str,"<","%3c"),"""","%22"),"'","%27")

End function


private function LD_GetUrl(dir)

	dim d : d = Request.ServerVariables("server_name")
	dim p : p = Request.ServerVariables("SERVER_PORT")
	if p <> "80" Then d = d & Server.UrlEncode(p)
	
	if dir = 1 then '返回论坛安装目录
		d = d & DEF_Installdir
	elseif dir = 2 then '返回当前文件url
		d = d & Request.Servervariables("SCRIPT_NAME")
	else
		d = ""
	end if
	
	dim pl : pl = Request.ServerVariables("SERVER_PROTOCOL")
	dim t
	t = inStr(pl,"/")
	if t > 0 then
		pl = left(LCase(pl), t - 1)
	end if

	dim s
	if Request.ServerVariables("HTTPS") <> "on" then
		s = ""
	else
		s = "s"
	end if
	LD_GetUrl = pl & s & "://" & d

end function

End Class
%>