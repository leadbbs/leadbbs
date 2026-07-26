<%
const Unbind_limit = 0

Sub DisplayBind

	Dim ConnetBind
	set ConnetBind = New Connet_Bind
	ConnetBind.BindList
	set ConnetBind = nothing

End Sub

Sub Unbind

	If GBL_CHK_OnlineTime < Unbind_limit then
		Response.Write "无法立即解除绑定，" & DEF_PointsName & "高于120才能进行此操作."
		Exit Sub
	End If
	dim apptype
	apptype = toNum(request.querystring("apptype"),0)
	if apptype > 0 then
		call ldexecute("delete from leadbbs_applogin where userid=" & GBL_UserID & " and apptype=" & apptype,1)
		Response.Write "成功解除绑定."
	end if

End Sub

Class Connet_Bind

	private BindType 
	private BindTongBuName
	private BindLoginUrl
	private BindMethod

	Private Sub Class_Initialize
	
		BindType = connect_apptype
		BindTongBuName = array("腾讯QQ空间","腾讯微博","微博","百度","支付宝","人人网","开心网","天翼","优酷")
		dim n
		redim BindLoginUrl(ubound(BindType))
		for n = 0 to ubound(BindType)
			BindLoginUrl(n) = ("app/qqlogin/login.asp?apptype=" & BindType(n))
		next
		BindMethod = array("发表帖子","回复帖子","评论","收藏")
	
	End Sub
	
	Public Sub BindList
	
		dim rs,sql,getdata,num,Retention1
		sql = "select id,appid,Token,appType,Retention1 from leadbbs_applogin where userid=" & GBL_UserID & " order by apptype asc"
		set rs = ldexecute(sql,0)
		If rs.eof then
			num = -1
		else
			getdata = rs.getrows(-1)
			num = Ubound(GetData,2)
		end if
		rs.close
		set rs = nothing
		dim n,i,exist,m
		%>
		<script>
		function unbind(n,url)
		{
			getAJAX('LookUserInfo.asp?Evol=unbind&apptype='+n+'&t='+Math.random(),'','$id("unbind'+n+'").innerHTML="<a href=<%=DEF_BBS_HomeUrl%>'+url+' class=\'fmbtn btn_3 inline\' target=_blank>立即绑定</a>";',1);return false;
		}
		</script>
		<%
		dim qc
		SET qc = New QqConnet
		set qc = nothing
		for n = 0 to ubound(BindType)
			if connect_allow(n) = 1 then
				exist = 0
								%>
								<div class="value" style="height:42px;line-height:42px;border-bottom:#ccc 1px dashed">
								<span style="width:120px;display:block;float:left;"><img src="<%=DEF_BBS_HomeUrl%>images/app/<%=BindType(n)%>.png" class="absmiddle" />
								<%=connect_list(n)%></span>
								<%
				for i = 0 to num
					if BindType(n) = GetData(3,i) then
						exist = 1
						
						Retention1 = ccur(toNum(GetData(4,i),0))
						select case BindType(n)
							Case else:
								%>
								<span id="unbind<%=BindType(n)%>">
								<%
								for m = 0 to ubound(BindMethod)
									%>
									<label><input type="checkbox" class=fmchkbox name="Limit_<%=BindType(n)%>_<%=m%>" value="1"<%
									If GetBinarybit(Retention1,m+1) = 0 Then
										Response.Write " checked>"
									Else
										Response.Write ">"
									End If%><%=BindMethod(m)%></label>
										<%
								next
								If GBL_CHK_OnlineTime >= Unbind_limit then
								%>
								<a href="javascript:;" onclick="unbind(<%=BindType(n)%>,'<%=BindLoginUrl(N)%>');" class="fmbtn btn_3 inline">解除绑定</a>
								</span>
								<%
								Else
									%>
									在线一定时间才能解除绑定
									<%
								End If
						end select
					end if
				next
	 			If exist = 0 then%>
					<a href="<%=DEF_BBS_HomeUrl%><%=BindLoginUrl(N)%>" class="fmbtn btn_3 inline" target=_blank>立即绑定</a>
					<%
				end if
				%>					</div>
				<%
			end if
		next
	
	End Sub

	Public Sub BindAnnounceList
	
		dim rs,sql,getdata,num,Retention1
		sql = "select id,appid,Token,appType,Retention1 from leadbbs_applogin where userid=" & GBL_UserID & " order by apptype asc"
		set rs = ldexecute(sql,0)
		If rs.eof then
			num = -1
		else
			getdata = rs.getrows(-1)
			num = Ubound(GetData,2)
		end if
		rs.close
		set rs = nothing
		if num = -1 then exit sub
		dim n,i,exist,m
		%>
		<script>
		function toggleBind(n)
		{
			if($(n).prev().attr("value")=="1")
			{
				$(n).prev().val("0")
				$(n).next().attr("class","");
			}
			else
			{
				$(n).prev().val("1")
				$(n).next().attr("class","select");
			}
		}
		</script>
		<div class="value bindpost"><span id="api_syncstring">同步到：</span>
		<%
			dim weiboflag,qqflag
			weiboflag = 0
			qqflag = 0
			
			dim pclass,pVal
			if GetBinarybit(GBL_CHK_UserLimit,19) = 1 then
				pclass = ""
				pVal = "0"
			else
				pclass = "select"
				pVal = "1"
			end if
			
		dim qc
		SET qc = New QqConnet
		set qc = nothing
		
		dim has : has = 0
		for n = 0 to ubound(BindType)
		if connect_allow(n) = 1 then
			exist = 0
			for i = 0 to num
				if BindType(n) = GetData(3,i) and GetData(2,i) & "" <> "" then
					exist = 1			
					Retention1 = ccur(toNum(GetData(4,i),0))
					select case BindType(n)
						Case 1:
							qqflag = 1
							'has = 1
							%>
							<!--
							<span class="item">
							<input type="hidden" name="bindpost_<%=BindType(n)%>" value="<%=pVal%>">
							<a href="javascript:;" id="LD_Bind1" title="同步到<%=BindTongBuName(n)%>" onclick="toggleBind(this);return false;" class="bindpost_icon_s" style="background-position:0 0px"></a><em onclick="toggleBind($id('LD_Bind1'));return false;" class="<%=pclass%>"></em>
							</span>
							// -->
							<%
						case 2:
							has = 1
							weiboflag = 1%>						
							<span class="item">
							<input type="hidden" name="bindpost_<%=BindType(n)%>" value="<%=pVal%>">
							<a href="javascript:;" id="LD_Bind<%=BindType(n)%>_1" title="同步到<%=BindTongBuName(n)%>" onclick="toggleBind(this);return false;" class="bindpost_icon_s" style="background-position:0 -<%=(BindType(n)-1)*32%>px"></a><em onclick="toggleBind($id('LD_Bind<%=BindType(n)%>_1'));return false;" class="<%=pclass%>"></em>
							</span>
						<%
						
						case 3,6,7:
							has = 1
							%>						
							<span class="item">
							<input type="hidden" name="bindpost_<%=BindType(n)%>" value="<%=pVal%>">
							<a href="javascript:;" id="LD_Bind<%=BindType(n)%>_1" title="同步到<%=BindTongBuName(n)%>" onclick="toggleBind(this);return false;" class="bindpost_icon_s" style="background-position:0 -<%=(BindType(n)-1)*32%>px"></a><em onclick="toggleBind($id('LD_Bind<%=BindType(n)%>_1'));return false;" class="<%=pclass%>"></em>
							</span>
						<%
						case else
					end select
				end if
			next
		end if
		next
				if qqflag = 1 and weiboflag = 0 then
					has = 1
					%>
							<span class="item">
							<input type="hidden" name="bindpost_1_1" value="<%=pVal%>">
							<a href="javascript:;" id="LD_Bind1_1" title="转发到腾讯微博" onclick="toggleBind(this);return false;" class="bindpost_icon_s" style="background-position:0 -32px"></a><em onclick="toggleBind($id('LD_Bind1_1'));return false;" class="<%=pclass%>"></em>
							</span><%
				end if
				
				if has = 0 then
				%>
 							<script>$("#api_syncstring").hide();</script>
							<%
				end if
		%>
		</div>
		<%
	
	End Sub
	
	Public Sub PostShare(appType,title,turl,comment,summary,images,weibo,video)
	
		dim rs,sql,getdata,num,Token,appid,ExpiresTime
		sql = "select id,appid,Token,appType,Retention1,ExpiresTime from leadbbs_applogin where userid=" & GBL_UserID & " and apptype=" & appType
		set rs = ldexecute(sql,0)
		If rs.eof then
			num = -1
		else
			num = 1
			Token = Rs(2)
			appid = Rs(1)
			ExpiresTime = ccur("0" & Rs(5))
			if ExpiresTime = 0 then
				ExpiresTime = DateDiff("s",600,DEF_Now)
			else
				ExpiresTime = RestoreTime(ExpiresTime)
			end if
		end if
		rs.close
		set rs = nothing
		If num = -1 Then exit Sub
		dim qc
		Select case appType
			Case 1:
				set qc = New QqConnet
				if weibo = 2 or weibo=1 then
					call qc.Post_Webo(title & " / " & turl & " / " & comment & " / " & summary,Token,appid)
				end if
				if weibo = 2 or weibo=0 then
					call qc.Post_Share(apptype,title,turl,comment,summary,images,0,Token,appid,video,ExpiresTime)
				end if
				set qc = nothing
			case else
				set qc = New QqConnet
				call qc.Post_Share(apptype,title,turl,comment,summary,images,0,Token,appid,video,ExpiresTime)
				set qc = nothing
		End Select
	
	End Sub

End Class

%>