<!--#include file="AD_Data.asp"-->
<%
Function AD_GetAdString

	Randomize
	AD_GetAdString = DEF_AD_DataArray(Fix(Rnd*DEF_AD_DataNum))

End Function
%>