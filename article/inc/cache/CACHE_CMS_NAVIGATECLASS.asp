<%
Dim CMS_NAVIGATECLASS_UpdateTime
CMS_NAVIGATECLASS_UpdateTime = "2014/4/24 0:35:07"

Sub CMS_NAVIGATECLASS_View

%>
<%
dim classid
classid = tonum(request.querystring("classid"),0)
%>
<div class="munu_nav2 fire">
<div class="layer_item3"><a class="cms_top_item" href="<%=DEF_BBS_HomeUrl%>article/article.asp?classid=1" id="cmstopitem1"><span class="head_item_title">¹«¸æ</span></a>
</div></div>
<script>
$("#cmstopitem<%=classid%>").attr("class","cms_top_sel");
</script>
<%

End Sub
%>
