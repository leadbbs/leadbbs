<%Option Explicit%>
<!-- #include file=scripts/install_fun.asp -->
<!-- #include file=../inc/md5.asp -->
<%
Server.ScriptTimeOut = 6000
const DEF_FSOString = "Scripting.FileSystemObject"
const DEF_BBS_HomeUrl = "../"
Dim Step,Check_com,GBL_CHK_TempStr,con,setupstr,constr,dtype
dim adminuser,adminpassword,adminpassword2

Check_com = True

Sub Main

	Step = toNum(left(Request("Step"),1),1)
	If Step > 5 then Step = 1
	install_head
	install_contenthead
	install_step
	if checkInstalled = false then
		select case step
		case 1:
			install_step1form
		case 2:
			install_step2form
		case 3:
			install_step3form
		case 4:
			install_step4form
		case 5:
			install_step5form
		end select
	end if
	install_contentbottom
	install_bottom

End Sub

Main

%>