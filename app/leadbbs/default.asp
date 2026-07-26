<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=inc/musicbox_fun.asp -->
<!-- #include file=../../inc/User_Setup.asp -->
<%
DEF_BBS_HomeUrl = "../../"


Main

Sub Main

	dim tmp
	Select Case left(Request("file"),5)
		Case "":
			set tmp = new Plug_MusicBar_Music_class
			tmp.Plug_MusicBar_Music
			set tmp = nothing
		Case "music":
			set tmp = new Plug_MusicBar_Music_class
			tmp.Plug_MusicBar_Music
			set tmp = nothing
		Case "medal":
			plug_medal_get
		Case "edit":
			set tmp = new Plug_MusicBar_Music_class
			tmp.Plug_MusicBar_Edit
			set tmp = nothing
	End Select

End Sub

Sub Plug_Medal_Get

	dim tmp
	set tmp = new Plug_Medal_class
	set tmp = nothing

End Sub

class Plug_Medal_class

	private medal_info,submit,medalid
	
	Private Sub Class_Initialize
	
		redim medal_info(6)
		medal_info(0) = "5|需要为LeadBBS录制一期广播并审核通过||"
		medal_info(1) = "6|需要论坛龄10岁|6,8|datediff(""d"",applytime,DEF_Now)>=3650"
		medal_info(2) = "7|||"
		medal_info(3) = "8|需要论坛龄5岁|6,8|datediff(""d"",applytime,DEF_Now)>=1825"
		medal_info(4) = "9|需要经验突破525600（365天）|9,10|onlinetime>=525600*60"
		medal_info(5) = "10|需要经验突破21900（365小时）|9,10|onlinetime>=21900*60"
		initdatabase
		
		submit = left(request.form("submit"),1)
		medalid = toNum(request("medalid"),-1)
		
		If submit <> "1" then
	%>
<!DOCTYPE html> 
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=GBK">
<title>用户<%=DEF_PointsName(9)%></title> 
<link rel="stylesheet" type="text/css" href="images/css.css">
<script type="text/javascript" src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.js"></script>
<script type="text/javascript" src="<%=DEF_BBS_HomeUrl%>inc/js/common.js"></script>
<style>

body{padding:0px;margin:20px;}
*{font-size:9pt !important;}
.plug_medal_list{list-style:none;margin:0px;padding:0px;width:520px;
overflow-y:auto;
height:420px;
height: expression((this.scrollHeight>420px)?420px:this.scrollHeight-22+'px');
}
.plug_medal_list li{line-height:60px;height:60px;}
.absmiddle{vertical-align: middle;margin-top:0px;}
.plug_medal_img{width:48px;height:48px;background:#b3dcef;border-radius:5px;border:1px #7acef4 solid; margin-right:12px;float:left;}
.plug_medal_img img{margin-left:14px;margin-bottom:12px;_margin-top:12px;}
a.plug_medal_none,a.plug_medal_get{width:48px;height:48px;color:#fff;font-weight:bold;line-height:48px;background:#ff6600;border-radius:5px;border:1px yellow solid; margin-left:12px;
float:left;text-align:center;margin-right:24px;}
a.plug_medal_none{background:#ccc !important;color:#888;border:1px #ccc solid !important;}
a.plug_medal_get:hover{background:#ffdf5f;color:#000;}
.plug_medal_info{float:left;width:320px;margin-right:24px;overflow:hidden;text-overflow: ellipsis;white-space:nowrap;word-wrap:normal;
color:gray;
}
.plug_medal_info b{color:#000;}
</style>
</head>
<body>
		<%
end if
		medal_list
		
If submit <> "1" then%>
</body>
</html>
	<%
end if
		closedatabase
	end sub

	private sub medal_list
	
		Dim Sex,Birthday,ApplyTime,UserLevel,Points,Officer,OnlineTime,AnnounceNum,LastDoingTime
		Dim UserLimit,AnnounceTopic,AnnounceGood,UploadNum,CharmPoint,CachetValue,ExtendFlag,TrueName
		Dim AnnounceNum2
		Dim sql,rs
		sql = sql_select("select * from LeadBBS_User where id=" & GBL_UserID,1)
		set rs = ldexecute(sql,0)
		if not rs.eof then
			Sex = rs("Sex") & ""
			Birthday = gettimevalue(rs("Birthday"))
			ApplyTime = RestoreTime(rs("ApplyTime"))
			UserLevel = ccur(rs("UserLevel"))
			Points = ccur(rs("Points"))
			Officer = "," & rs("Officer") & ","
			OnlineTime = ccur(rs("OnlineTime"))
			AnnounceNum = ccur(rs("AnnounceNum"))
			LastDoingTime = RestoreTime(rs("LastDoingTime"))
			UserLimit = ccur(rs("UserLimit"))
			AnnounceTopic = ccur(rs("AnnounceTopic"))
			AnnounceGood = ccur(rs("AnnounceGood"))
			UploadNum = ccur(rs("UploadNum"))
			CharmPoint = ccur(rs("CharmPoint"))
			CachetValue = ccur(rs("CachetValue"))
			ExtendFlag = ccur(rs("ExtendFlag"))
			TrueName = rs("TrueName") & ""
			AnnounceNum2 = ccur(rs("AnnounceNum2"))
		end if
		rs.close
		set rs = nothing
	
		dim Num,arr,n
		Num = Ubound(medal_info)
		
		Dim MedalName,tmp,allow,medalclass,clickstr
		dim HrefName
		
		Dim MoreImp,i
		
		if submit = "1" then
			if medalid < 0 or medalid > ubound(medal_info) then exit sub
			
			arr = split(medal_info(medalid),"|")			
			
			if GBL_UserID < 1 then
				Response.Write "未登录."
				exit sub
			end if

			if arr(3) <> "" then
				if eval(arr(3)) <> true then
					Response.Write "不符合领取要求."
					exit sub
				end if
			end if
			if inStr(Officer,"," & arr(0) & ",") then
				Response.Write "已领取过."
				exit sub
			end if
			
			arr(2) = "," & arr(2) & ","
			
			
			dim old_officer
			old_officer = officer
			if left(officer,1) <> "," then officer = "," & officer
			if right(officer,1) <> "," then officer = officer & ","
			officer = replace(officer,",",",,")

			if inStr(arr(2),"," & arr(0) & ",") then
				MoreImp = Split(arr(2),",")
				for i = 0 to ubound(MoreImp)
					if MoreImp(i) <> "" then
						if inStr(Officer,"," & MoreImp(i) & ",") then
							if (inStr(arr(2),"," & MoreImp(i) & ",") > 0 and inStr(arr(2),"," & arr(0) & ",") > 0) and inStr(arr(2),"," & MoreImp(i) & ",") < inStr(arr(2),"," & arr(0) & ",") then
								Response.Write "你已拥有更高级的" & DEF_PointsName(9) & "."
								exit sub
							else
								officer = replace(officer,"," & MoreImp(i) & ",","")
							end if
						end if
					end if
				next
			end if
			
			officer = replace(officer,",,",",")
			if replace(officer,",","") = "" then
				officer = ""
			else
				if left(officer,1) = "," then officer = mid(officer,2)
				if right(officer,1) = "," then officer = mid(officer,1,len(officer)-1)
			end if
			
			if officer <> "" then
				officer = officer & "," & arr(0)
			else
				officer = arr(0)
			end if
			
			if(Officer<>old_Officer) then
				sql = "update leadbbs_user set Officer='" & replace(Officer,"'","''") & "' where id=" & GBL_UserID
				call ldexecute(sql,1)
				Response.Write "成功领取!"
			end if
			
			exit sub
		end if
		%>
		<script>
		function get_done(i,tmp)
		{
			$("#"+i).html("已领取");
			$("#"+i).attr("class","plug_medal_none");
			$("#"+i).click(function(){return false;});
			$("#"+i).attr("onclick","return false;")
			alert(tmp);
		}
		</script>
		<ul class="plug_medal_list">
		<%
		for n = 0 to Num-1
			arr = split(medal_info(n),"|")
			arr(2) = "," & arr(2) & ","
			allow = 0
			arr(3) = trim(arr(3))
			if arr(3) <> "" and GBL_UserID > 0 then
				if eval(arr(3)) = true then allow = 1
			end if
			
			if allow = 1 then
				medalclass = "plug_medal_get"
				clickstr = "getAJAX(this.href,'submit=1','get_done(\''+this.id+'\',tmp);',1);return false;"
			else
				medalclass = "plug_medal_none"
				clickstr = "alert('不符合领取要求.');return false;"
			end if
			
			HrefName = "领取"
			if arr(3) = "" then
				HrefName = "未开放"
				clickstr = "alert('暂未开放领取.');return false;"
			end if
			if inStr(Officer,"," & arr(0) & ",") then
				HrefName = "已领取"
				medalclass = "plug_medal_none"
				clickstr = "return false;"
				allow = 0
			end if
			
			if inStr(arr(2),"," & arr(0) & ",") then
				MoreImp = Split(arr(2),",")
				for i = 0 to ubound(MoreImp)
					if MoreImp(i) <> "" then
						if inStr(Officer,"," & MoreImp(i) & ",") then
							if (inStr(arr(2),"," & MoreImp(i) & ",") > 0 and inStr(arr(2),"," & arr(0) & ",") > 0) and inStr(arr(2),"," & MoreImp(i) & ",") < inStr(arr(2),"," & arr(0) & ",") then
								HrefName = "过期"
								medalclass = "plug_medal_none"
								allow = 0
								clickstr = "alert('你已拥有更高级的" & DEF_PointsName(9) & ".');return false;"
								exit for
							end if
						end if
					end if
				next
			end if
			%>
			<li>
			<span class="plug_medal_img">
			<img class="absmiddle" src="<%=DEF_BBS_HomeUrl%>images/blank.gif" class="img_medal_big" style="width:20px;height:20px;background:url(../../images/others/medal_icons.png) no-repeat;background-position:-<%=arr(0)*39%>px -28px;">
			</span>
			<a href="Default.asp?file=medal&medalid=<%=n%>" id="getmedal<%=n%>" class="<%=medalclass%>" onclick="<%=clickstr%>"><%=HrefName%></a>
			<span class="plug_medal_info">
			<%
			tmp = DEF_UserOfficerString(arr(0))
			if inStr(tmp,"|") then
				tmp = split(tmp,"|")
				MedalName = tmp(0)
			else
				MedalName = tmp
			end if
			%>
			<b><%=MedalName%></b>
			<%=arr(1)%>
			</span>
			</li>
			<%
		next
		%>
		</ul>
		<%
	
	end sub
	
end class
%>