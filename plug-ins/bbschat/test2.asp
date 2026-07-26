<%
DEF_MasterCookies = "as"

Function ListApplicationMemory

	Response.Write "<p><b>论坛Applicaton数据列表：</b><table>" & VbCrLf
	Dim Thing
	For Each Thing in Application.Contents
		If Left(Thing,Len(DEF_MasterCookies)) = DEF_MasterCookies Then
			Response.Write "<tr><td><font color=Gray class=grayfont>" & thing & "</font></td><td>&nbsp;"
			If isObject(Application.Contents(Thing)) Then
				Response.Write "对象"
			ElseIf isArray(Application.Contents(Thing)) Then
				Response.Write "数组"
			Else
				Response.Write Application.Contents(Thing)
			End If
			Response.Write "</td></tr>"
		End If
	Next
	Response.Write "</table>"

End Function

Sub c_ViewOnlineUser

	Response.Write "<p><b>在线人员</b><table>" & VbCrLf
	Dim Thing
	Dim tmp,tmp1
	tmp = len(DEF_MasterCookies & "_Chat_S_Data_")
	tmp1 = DEF_MasterCookies & "_Chat_S_Data_"
	For Each Thing in Application.Contents
		If Left(Thing,tmp) = tmp1 Then
			Response.Write "<tr><td><font color=Gray class=grayfont>" & Mid(thing,tmp+1) & "</font></td><td>&nbsp;"
			Response.Write "</td></tr>"
		End If
	Next
	Response.Write "</table>"

End Sub

ListApplicationMemory
c_ViewOnlineUser
%>