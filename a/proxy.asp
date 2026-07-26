<%@ LANGUAGE=VBScript CodePage=65001%>
<%Option Explicit
Response.Charset = "utf-8"
Session.CodePage=65001%>
<!--#include file="inc/proxy_fun.asp"-->
<%
rem LeadBBS代理参数
rem u - 地址
rem bin - 是否二进度输出(1)
rem utf8 - 是否utf8编码输出(1)

Sub Proxy_Main

	Dim MyProxy
	Set MyProxy = New Proxy_Class
	dim callback
	callback = request.querystring("callback")
	if callback <> "" then
		Response.Write callback & "("
	end if

	dim refer : refer = Request.Servervariables("HTTP_REFERER")
	refer = replace(replace(refer,"\","/"),"http://","")
	if inStr(refer,"/") then refer = mid(refer,1,inStr(refer,"/")-1)
	if inStr(refer,":") then refer = mid(refer,1,inStr(refer,":")-1)
	If Lcase(Request.ServerVariables("server_name")) <> lcase(refer) then
		'Response.Write "null"
		if callback <> "" then response.write ")"
		'response.end
	end if
	
	dim u
	u = Request.QueryString("u")
	if u = "" then u = Request.form("u")
	MyProxy.GetBody(Request.QueryString("u"))
	if callback <> "" then response.write ")" & VbCrLf
	Set MyProxy = Nothing

End Sub

Proxy_Main()
%>