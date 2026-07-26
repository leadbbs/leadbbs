<%
Str = Str & "		<div class=""content_side_box"">" & VbCrLf &_
"			<div class=""title""><b>最新精华</b></div>" & VbCrLf &_
"			" & Topic_AnnounceList(0,10,0,"yes","1","0","") & VbCrLf &_
"		</div>" & VbCrLf
Str = Str & "		<div class=""content_side_box"">" & VbCrLf &_
"			<div class=""title""><b>最新主题</b></div>" & VbCrLf &_
"			" & Topic_AnnounceList(0,10,0,"yes","0","0","") & VbCrLf &_
"		</div>" & VbCrLf
%>