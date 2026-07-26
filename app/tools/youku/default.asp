<!-- #include file=../../../inc/BBSsetup.asp -->
<%
Dim DEF_EXTEND_ClassType : DEF_EXTEND_ClassType = 3001 '优酷视频上传信息扩展类型编号为3001
Dim DEF_EXTEND_Level : DEF_EXTEND_Level = 100 '优酷视频上传信息扩展类型编号为3001
'Response.Charset = "utf-8"
'Session.CodePage = 65001
%>
<!-- #include file=../../../inc/UBBCode_Setup.asp -->
<!-- #include file=../../../inc/Board_popfun.asp -->
<!-- #include file=../../../app/qqlogin/oauth.asp -->
<!-- #include file=../../../article/inc/splitpage_fun.asp -->
<%
DEF_BBS_homeUrl="../../../"
dim Uploadyouku
set Uploadyouku = new Upload_youku
Uploadyouku.uploadForm
set Uploadyouku = nothing


class Upload_youku

	private client_id,access_token,errstr,openid

	private sub initUpload
	
		client_id = youku_apikey
		if client_id = "" then
			errstr = "网站未开通YOUKU互联功能，无法使用此功能．"
			exit sub
		end if
		if gbl_userid < 0 then
			errstr = "请先登录论坛．"
			closedatabase
			exit sub
		end if
		
		if(App_CheckAppid(gbl_userid)) = 0 then
			exit sub
		end if
	
	end sub
	
	
	Public Function App_CheckAppid(userid)

		Dim Rs,exp
		Set Rs = LDExeCute(sql_select("Select UserID,appid,Token,ExpiresTime from LeadBBS_AppLogin where userid=" & userid & " and apptype=9",1),0)
		If Rs.Eof Then
			App_CheckAppid = 0
			errstr = "要使用此功能，需要先绑定YOUKU帐号．<a href=""" & DEF_Installdir & "user/" & RW_User(0,"bind","","") & """ target=_blank>点此关联</a>."
		Else
			App_CheckAppid = 1
			openid = rs(1)
			access_token = rs(2)
			exp = ccur("0" & Rs(3))
			if exp > 0 then
				if gettimevalue(DEF_Now) > exp then
					App_CheckAppid = 0
					errstr = "您与优酷的帐号绑定已过期，需要取消绑定后重新绑定．<a href=""" & DEF_Installdir & "user/" & RW_User(0,"bind","","") & """ target=_blank>点此关联</a>."
				end if
			end if
		End if
		Rs.Close
		Set Rs = Nothing

	End Function
	
	private sub upload_save
		
		dim videoid,title
		videoid = trim(uniDecode(left(request("videoid"),32)))
		title = trim(uniDecode(left(request("title"),255)))
		if len(videoid) < 5 then
			exit sub
		end if
		
		'extent_num 作为保存时间用
		dim rs,sql,extent_num,extent_title
		sql = sql_select("select extent_num,extent_title from leadbbs_extend where classtype=" & DEF_EXTEND_ClassType & " and extendid=" & GBL_userid & " order by id desc",1)
		set rs = ldexecute(sql,0)
		if not rs.eof then
			extent_num = ccur(rs(0))
			extent_title = rs(1)
			if extent_title = videoid then
				rs.close
				set rs = Nothing
				exit sub
			end if
			if extent_num > 0 then
				extent_num = restoretime(extent_num)
				'保存太频的不会提交
				if datediff("s",extent_num,DEF_Now) < 10 then
					rs.close
					set rs = Nothing
					exit sub
				end if
			end if
		end if
		rs.close
		set rs = Nothing
		
		call insert_LeadBBS_extend(-2,DEF_EXTEND_ClassType,gbl_userid,videoid,title,gettimevalue(DEF_Now),0,DEF_EXTEND_Level)

	end sub
	
	private sub other_head%>
	
	
<html>
<head>
<link href="http://open.youku.com/assets/lib/bootstrap2.1.0/css/bootstrap.css" rel="stylesheet">
    <link href="http://open.youku.com/assets/lib/bootstrap2.1.0/css/bootstrap-responsive.css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=gbk" />
<style>
#txtFileName{height:32px !important;display:inline-block;margin-bottom:6px;}
#success{font-weight:bold;font-size:16px;width:100%;text-align:center;color:blue;}

.youku_nav{margin-top:12px;width:360px;display:block;margin-left:auto;*margin-left:60px;margin-right:auto;}
.youku_nav a{float:left;border: #ccc 1px solid;border-radius:6px;padding:3px 6px 3px 6px;margin-right:12px;margin-bottom:12px;}
.pagelimit{height:700px !important;overflow-y:auto;}
.radio input{*width:20px!important;}
.well{margin-top:0px!important;padding-top:0px!important;}

.control-group,.form-actions,.row,.well{*width:90%;}
form{margin-bottom:0px!important;padding-bottom:0px!important;}
table .span5{width:100%!important;}
#youku-upload .row{position:relative;left:30px;width:80%!important;}
#youku-upload button{float:left!important;margin-left:50px;margin-top:30px;margin-bottom:30px;}
</style>

</head>
<body>
<table class="pagelimit"><tr><td>
<div class="youku_nav">
<a href="default.asp?action=list">所有上传</a>
<a href="default.asp?action=list&userid=<%=gbl_userid%>">我的上传</a>
<a href="default.asp">上传视频</a>
</div>
<div style="clear:both;"></div>
	<%
	end sub

	public sub uploadForm
	
		initdatabase
		initUpload
		if errstr = "" then
			if request.querystring("action") = "save" then
				upload_save
				exit sub
			end if
		end if
if request.querystring("action") = "list" then
%>
<html>
<head>
<link href="http://open.youku.com/assets/lib/bootstrap2.1.0/css/bootstrap.css" rel="stylesheet">
    <link href="http://open.youku.com/assets/lib/bootstrap2.1.0/css/bootstrap-responsive.css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=gbk" />
<style>
#txtFileName{height:32px !important;display:inline-block;margin-bottom:6px;}
#success{font-weight:bold;font-size:16px;width:100%;text-align:center;color:blue;}
</style>

		<style>
		.pagelimit{height:700px;overflow-y:auto;}
		.youkulist{list-style:none;margin:12px 0 0 30px;border-top:#ccc 2px dotted;padding:0;}
		.youkulist li{padding:10px 0 0 0;margin:0 0 30px 0;text-align:left;}
		.youkulist .title{font-size:14px;height:32px;line-height:32px;color:green;font-weight:bold;}
		.youkulist .user{margin-left:12px;height:32px;line-height:32px;}
		.youkulist .time{font-size:10px;color:gray;}
		.j_page{margin-left:30px;margin-top:12px;}
		

.lrc_content ul,.lrc_content ol,.lrc_content dl { list-style:none; font-size:12px;}
.lrc_content li{line-height:200%;}
.lrc_content li.hover{ color:red; }
.lrc_content{ width:402px; height:200px; background:#ccc; overflow:hidden; padding:10px;}
.lrc_item{width:120px;height:90px;background: #a1d7f0;border:#7acef4 1px solid;display:inline-block;position:relative;overflow:hidden;text-align:center;}
.lrc_item .lrc_content{display:none;}
.lrc_item .lrc_source{background: url("../../../images/style/extend/01002/mediaplay.png") no-repeat;font-size:14px;color:#333;line-height:90px;text-shadow: 0 1px 0 #eee;padding:0px;height:100%;display:block;}
a.lrc_source:hover{background: url("../../../images/style/extend/01002/mediaplay_over.png") no-repeat;}
.lrc_item .lrc_source img{position:absolute;left:0px;top:0px;width:120px;height:90px;}
.video_play{left:50%;
top:50%;
display:block;
position:absolute;
background: url("../../../inc/js/jplayer/css/video_play.png") no-repeat 0px 0px;
width: 50px;
height: 50px;
margin-left:-25px;
margin-top:-25px;
text-indent:-9999px;
}
.lrc_close {color:gray !important;display:block;height:32px;line-height:32px;font-size:9pt;}
#jplayer{text-align:left;}
.table_options .note .lrc_source span{display:none;}
.youku_nav{margin-top:12px;width:360px;display:block;margin-left:auto;margin-right:auto;}
.youku_nav a{float:left;border: #ccc 1px solid;border-radius:6px;padding:3px 6px 3px 6px;margin-right:12px;}
		</style>
	

	<script type="text/javascript">
	var DEF_MasterCookies = "<%=htmlencode(DEF_MasterCookies)%>";
	var GBL_Style = "<%=GBL_Board_BoardStyle%>";
	var HU = "../../../";
	var GBL_domain="|<%=DEF_AbsolutHome%>|<%=DEF_SafeUrl%>|";
	var DEF_DownKey="<%=UrlEncode(DEF_DownKey)%>";
	</script>
		<script src="<%=DEF_InstallDir%>inc/js/jquery.js"></script>
		<script src="<%=DEF_installDir%>inc/js/common.js<%=DEF_Jer%>" type="text/javascript"></script>

		<script src="<%=DEF_installDir%>a/inc/leadcode.js<%=DEF_Jer%>" type="text/javascript"></script>
		<script src="<%=DEF_installDir%>inc/js/plug/apijson.js?ver=2014030722" type="text/javascript"></script>

</head>
<body>
<div class="pagelimit">
<div class="youku_nav">
<a href="default.asp?action=list">所有上传</a>
<a href="default.asp?action=list&userid=<%=gbl_userid%>">我的上传</a>
<a href="default.asp">上传视频</a>
</div>
<div style="clear:both;"></div>
<%
	youku_list
	closedatabase
	%>
</div>
	</body>
	</html>
	<%
%>
<%
elseif errstr <> "" then
	other_head
	Response.write errstr
	closedatabase
else
	other_head
	closedatabase
	%>
 <script src="<%=DEF_InstallDir%>inc/js/jquery.js"></script>
    <!--<script src="http://open.youku.com/assets/lib/uploadjs.php"></script>-->
    <script src="upload.js"></script>
    
<div class="leadbbs_app">
<div id="success"></div>
  <div id="youku-upload">
        <div class="container">
            <form class="well form-horizontal" name="video-upload">
                <fieldset>
						<div class="control-group">
							<label class="control-label" for="spanSWFUploadButton">选择文件：</label>
							<div id="uploadControl" class="controls" style="></div>
						</div>
						<div class="control-group">
							<label>标题：</label>
							<div class="controls">
							<input type="text">
							</div>
						</div>
						<div class="control-group">
							<label class="control-label" for="input01">标题：</label>
							<div class="controls">
							<input type="text" class="input-xlarge" id="input01" name="title">
							</div>
						</div>
                <div class="control-group">
                    <label class="control-label" for="textarea">简介：</label>
                    <div class="controls">
                        <textarea class="input-xlarge" id="textarea" rows="3" name="description"></textarea>
                    </div>
                </div>
                   <div class="control-group">
                       <label class="control-label" for="input02">标签：</label>
                       <div class="controls">
                          <input type="text" class="input-xlarge" id="input02" name="tags">
                          <span class="help-inline"></span>
                      </div>
                   </div>
               <div class="control-group">
                    <label class="control-label" for="category-node">类别：</label>
                    <div class="controls">
                        <select id="category-node" name="category" ></select>
                     </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label">版权所有</label>
                   <div class="controls">
                   <label class="radio inline">
                        <input type="radio" name="copyright_type" id="copyright_type2" value="original" checked="">原创
                    </label>
                    <label class="radio inline">
                   <input type="radio" name="copyright_type" id="copyright_type1" value="reproduced">转载
               </label>
     </div>
    </div>
    <div class="control-group">
       <label class="control-label">视频权限</label>
          <div class="controls">
                 <label class="radio inline">
                   <input type="radio" name="public_type" id="public_type1" value="all" checked="">公开
                 </label>
                 <label class="radio inline">
                   <input type="radio" name="public_type" id="public_type2" value="friend">仅好友
                 </label>
                 <label class="radio inline">
                    <input type="radio" name="public_type" id="public_type3" value="password">输入密码观看
                 </label>
                 <label class="radio inline" style="display:none" id="passwrod">
                    <input type="text" class="input "name="watch_password">
                 </label>
         </div>
    </div>
    <div class="form-actions">
            <button type="submit" class="btn btn-primary start" id="btn-upload-start">
             <i class="icon-upload icon-white"></i>
        <span>开始上传</span>
        </button>
    </div>
    </fieldset>
    </form>
    <div class="row" >
        <div class="span5" id="upload-status-wraper" ></div>
    </div>
    <div class="well"><h3>说明</h3><ul><li>最大支持上传<strong>1 GB</strong> 视频文件</li><li>允许上传的视频格式为：wmv,avi,dat,asf,rm,rmvb,ram,mpg,mpeg,3gp,mov,mp4,m4v,dvix,dv,dat,</br>mkv,flv,vob,ram,qt,divx,cpk,fli,flc,mod。不符合格式的视频将会被丢弃，请确保视频格式的正确性，避免上传失败</li></ul>
    </div>
    </div>
    <!--完成上传的DOM和登录DOM 开始-->
    <div id="complete"></div>
    <div id="login" style="width:100%;height:100%;position:fixed;z-index:999;left:0px;top:0px;overflow:hidden;display:none;">
    </div>
    <!--完成上传的DOM和登录DOM 结束-->
</div>
  <script>
        //document.domain = "youku.com";
        var USE_STREAM_UPLOAD = true;
        jQuery(document).ready(function(){
            //Oauth授权的三种页面跳转方式iframe,newWindow,currentWindow
            //iframe跳转方式
            //var param = {client_id:"",access_token:"",oauth_opentype:"iframe",oauth_redirect_uri:"http://test.youku.com/youkuupload/oauth_result.html",oauth_state:"",completeCallback:"uploadComplete",categoryCallback:"categoryLoaded"};
            //newWindow新弹出窗口方式
            //var param = {client_id:"",access_token:"",oauth_opentype:"newWindow",oauth_redirect_uri:"http://test.youku.com/youkuupload/oauth_result_newwindow.html",oauth_state:"",completeCallback:"uploadComplete",categoryCallback:"categoryLoaded"};
            //currentWindow当前窗口方式
            //14003805
            /*
            var param = {client_id:"<%=client_id%>",access_token:"<%=access_token%>",oauth_opentype:"currentWindow",oauth_redirect_uri:"http://www.leadbbs.com/app/tools/youku/default.asp",oauth_state:"",completeCallback:"uploadComplete",categoryCallback:"categoryLoaded"};
            //var param = {client_id:"",access_token:"",oauth_opentype:"currentWindow",oauth_redirect_uri:"http://test.youku.com/youkuupload/upload.html",oauth_state:"",completeCallback:"uploadComplete",categoryCallback:"categoryLoaded"};
            var reg = new RegExp("(^|\\#|&)access_token=([^&]*)(\\s|&|$)", "i");
            if (reg.test(location.href)){
                    var access_token = unescape(RegExp.$2.replace(/\+/g, " "));
                    param.access_token = access_token;
            }
            */
            var param = {client_id:"<%=client_id%>",access_token:"<%=access_token%>",oauth_opentype:"currentWindow",oauth_redirect_uri:"http://www.leadbbs.com/test/youku/upload.htm",oauth_state:"",completeCallback:"uploadComplete",categoryCallback:"categoryLoaded"};
            youkuUploadInit(param);

       });
            //上传完成时回调方法
            var videoid,videotitle;
				//data:{videoid:escape(videoid).replace(/\%u/gi,"\\u").replace(/\%/gi,"\\u00"),title:escape(videotitle).replace(/\%/gi,"\\u00")},
            function uploadComplete(data){
            		videoid = data.videoid;
            		videotitle = data.title;
                    $.ajax({
						  url: "default.asp?action=save&videoid="+escape(videoid)+"&title="+escape(videotitle),
						  type:"GET",
						  error:function(){alert('error');},
						  success: function(d){
						  	alert(videotitle+" \u6210\u529F\u4E0A\u4F20!");
						  	$("#success").html("<a href='"+getswfurl(videoid)+"' target=_blank>\u70B9\u51FB\u67E5\u770B\u89C6\u9891\u6548\u679C : "+getswfurl(videoid)+"</a>");
						  }
						});
            }
            
            function getswfurl(id)
            {
            	return "http://player.youku.com/player.php/sid/"+id+"/v.swf"
            }

            //分类加载后回调方法
            function categoryLoaded(data){
            if(data.categories) {
                    var tpl = '';
                    for (var i=0; i<data.categories.length; i++) {
                    if(data.categories[i].term == 'Ads'){
                    tpl += '<option value="' + data.categories[i].term + '" selected>' + data.categories[i].label + '</option>';
                    }else{
                            tpl += '<option value="' + data.categories[i].term + '" >' + data.categories[i].label + '</option>';
                    }
            }
            $("#category-node").html(tpl);
        }
    }
//if($(window.parent.document))
//$(window.parent.document).find("#appFrame").load(function(){
//var main = $(window.parent.document).find("#appFrame,#appmain");
//var thisheight = $(document).height()+30;
//main.height(thisheight);
//});
    </script>
</td></tr></table>
</body>
</html>
<%
end if
	end sub
	
	private sub youku_list
	
		dim userid
		userid = fix(toNum(Request.querystring("userid"),0))
		
		dim class_sql,class_idname,class_selcolumn,class_page,sql_extend
		sql_extend = " where t1.classtype=" & DEF_EXTEND_ClassType & " and t1.extent_level=" & DEF_EXTEND_Level
		if userid > 0 then sql_extend = sql_extend & " and t1.extendid=" & userid
	
		dim rs,sql,RCount
		userid = fix(toNum(Request.form("rcount"),0))
		if rcount < 1 then
			sql = "select count(*) from leadbbs_extend as t1 " & sql_extend
			set rs = ldexecute(sql,0)
			if rs.eof then
				RCount = -1
			else
				RCount = ccur(rs(0))
			end if
			rs.close
			set rs = nothing
		end if

		class_page = 0
		class_sql = "select {~~~} from leadbbs_extend as T1 left join LeadBBS_User as T2 on T2.Id=T1.extendid " & sql_extend
		class_idname = "T1.id"
		class_selcolumn = "T1.id,T1.classtype,T1.extendid,T1.extent_title,T1.extent_content,T2.username,T2.truename,T1.extent_num"
		splitpage_orderstr = "T1.id desc"
		
		class_page = fix(toNum(Request("page"),0))
		
		splitpage_listNum = DEF_MaxListNum

		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,RCount)
		
		if splitpage_num >= 0 then
			DisplayYoukulist splitpage_getdata
		end if
		
		dim extendurl,tmp
		extendurl = ""
		if userid > 0 then tmp = "&userid=" & userid
		tmp = tmp & "&rcount=" & rcount
		CALL splitpage_viewpagelist("default.asp?action=list" & tmp,splitpage_maxpage,splitpage_page,"")
	
	end sub
	
	private sub DisplayYoukulist(d)
	
		dim n,max
		max = ubound(d,2)
		%>
		<ul class=youkulist>
		<%
		for n = 0 to max
			%>
			<li>
			<span class="title"><%=htmlencode(d(4,n))%></span>
			<span class="user"><a href="<%=DEF_installDir%>user/<%=RW_User(d(2,n),"A","","")%>" target=_blank><%=GetTrueName(d(5,n),d(6,n))%></a>
			<span class="time"><%=ConvertSimTimeString(restoretime(d(7,n)))%></span>
			</span>
			<br>
			<span class="flash" id="youku_flash<%=n%>">[flash=591,480]http://player.youku.com/player.php/sid/<%=htmlencode(d(3,n))%>/v.swf|<%=replace(htmlencode(d(4,n)),"|","")%>[/flash]</span>
			</li>
			<%
		next
		%>
		</ul>
		<script>
		$(".flash").each(function(){
			leadcode($(this).attr("id"));
		});
		init_pagesource();
		APIJSON.get_mediainfo();
		</script>
		 
		<%
		'PageExeCuteInfo
	
	end sub

end class%>