<!--#include file="inc/BBSsetup.asp"-->
<!--#include file="inc/User_Setup.ASP"-->
<!--#include file="inc/Board_Popfun.asp"-->
<!--#include file="article/inc/popfun.asp"-->
<!--#include file="inc/Fun/VierAnc_Fun.asp"-->
<%
DEF_BBS_HomeUrl = ""

Sub Main

	initdatabase()
	article_SiteHead("")
	main_body()
	%>
	
	<%
	Closedatabase()

End Sub

Sub main_body
%>
<div class="body_area_out">
<%cms_DisplayBBSNavigate("")
cms_imgmsg()
cms_bodyhead_index("homepage")
cms_bodyBottom%>


</div>
<%
cms_SiteBottom()

End Sub

sub cms_bodyhead_index(sideinfo)%>

<script src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.waterfall.js<%=DEF_Jer%>" type="text/javascript"></script>
<div class="clear cms_body_top"></div>
<div class="area">
<div class="cms_body_box">
<div class="cms_body">
<div class="main">
	<div class="content_side_right" id="p_side">
		<%
		dim cmscacheClass
		select case sideinfo
			case "homepage":
				set cmscacheClass = new cms_cache_Class
				cmscacheClass.CMS_HOMESIDE
				set cmscacheClass = nothing
		end select
		%>
	</div>
	<div class="content_main_right">
		<div class="content_main_2_right">
		<div class="content_main_body" id="waterfallselector">
		
<%
			set cmscacheClass = new cms_cache_Class
			cmscacheClass.CMS_HOMECONTENT
			set cmscacheClass = nothing
		%>
		<script>
		  $("#waterfallselector").waterfall({column_width:$(".cell").width(),cell_selector:'.cell',column_space:10,auto_imgHeight:true,insert_type:2,column_className:'cellclass',img_selector:"img"});
		</script>
		<%

		
End Sub


Sub cms_imgmsg

%>
	<div class="navigate1_sty_out">
	<div class="area">
		<div class="cms_nav1_div">
		<div class="content_side_box1" style="float:left;">
				<!--#include file="article/inc/home_bannerlist.asp"-->
			<%
	'Response.Write Topic_HomePicInfo(612,171,-10)
	%>
		</div>
			<div class="cms_homenavigate">
				<div class="cms_homenavigate2">
			<%
			dim cmscacheClass
			set cmscacheClass = new cms_cache_Class
			cmscacheClass.Announcement
			set cmscacheClass = nothing
			'response.write cms_listClass(1,3,"网站公告",19)
			%>
				</div>
			</div>
		</div>
	</div>
	</div>
<%

End Sub

Main()
%>
