<%
sub center_setchannel

		dim centersetchannelClass
		set centersetchannelClass = new center_setchannelClass_Class
		set centersetchannelClass = nothing
	
End sub


class center_setchannelClass_Class

	Private form_content,form_fileid,FileName,form_classname
	' README §35: a dimensioned array declared as a Class member is mis-sized by AxonASP
	' (`Private x(16)` yields UBound 0), so these six were one-element arrays and the
	' channel editor raised "Subscript out of range". ReDim'd in Class_Initialize instead.
	Private form_type(),form_title(),form_listnum(),form_id(),form_extendflag(),form_style()
	Private StyleItem
	
	rem type: 0.列出最新主题 1.列出最新精华 2.列出某(版面)专题帖子 3.列出某版面帖子 4.版面排行
	rem form_title: 频道名称
	rem form_listnum: 列出的记录数量
	rem form_id: 专题编号或是版面的编号
	rem form_extendflag: 如果是列出版面帖子(tppe为3)此参数才有效，0: 列出版面的精华 1: 列出版面的最新主题
	rem form_style: 显示样式,比如是否展示内容或是图片

	Private Sub Class_Initialize

		ReDim form_type(16) : ReDim form_title(16) : ReDim form_listnum(16)
		ReDim form_id(16) : ReDim form_extendflag(16) : ReDim form_style(16)
		StyleItem = Array("1|标题加大","2|展示内容提要","3|展示相关图片","4|有图片时隐藏标题","5|仅首条记录标题加大及展示图片","6|相关图片显示为大图片","7|记录顺序读取(旧的记录优先)")
		form_fileid = GetFormData("form_fileid")
		form_fileid = toNum(FormClass_CheckFormValue(form_fileid,"","int",0,"",0),0)
		form_content = ""
		private_getinfo()
		
		select case form_fileid
			'case 0:
			'	FileName = "inc/home_channellist.asp"
			case else:
				FileName = "inc/cache/home_channellist_" & form_fileid & ".asp"
		end select

		dim submitflag
		submitflag = GetFormData("submitflag")
		if submitflag = "" then
			private_getClassinfo()
			center_Class_Form()
		else
			private_getformdata()
		end if
	
	End Sub
	
	
	private sub private_getformdata
	
	
	rem Private form_type,form_title,form_listnum,form_id,form_extendflag,form_style
	
	rem type: 999.无类型，关闭状态 0.列出最新主题 1.列出最新精华 2.列出某(版面)专题帖子 3.列出某版面帖子 
	rem form_title: 频道名称
	rem form_listnum: 列出的记录数量
	rem form_id: 专题编号或是版面的编号
	rem form_extendflag: 如果是列出版面帖子(tppe为3)此参数才有效，0: 列出版面的精华 1: 列出版面的最新主题
		dim indexn
		form_content = ""
		Dim Temp2,TempN,N
		for indexn = 0 to 15
			form_type(indexn) = GetFormData("form_type" & indexn)
			select case form_type(indexn)
				case "0": form_type(indexn) = 0
					     form_id(indexn) = 0
					     form_extendflag(indexn) = 0
				case "1": form_type(indexn) = 1
					     form_id(indexn) = 0
					     form_extendflag(indexn) = 0
				case "2": form_type(indexn) = 2
					     form_id(indexn) = GetFormData("form_id" & indexn)
					     form_extendflag(indexn) = 0
				case "3": form_type(indexn) = 3
					     form_id(indexn) = GetFormData("form_id" & indexn)
					     form_extendflag(indexn) = GetFormData("form_extendflag" & indexn)
				case "4": form_type(indexn) = 4
					     form_id(indexn) = GetFormData("form_id" & indexn)
					     form_extendflag(indexn) = 0
				case "5": form_type(indexn) = 5
					     form_id(indexn) = toNum(GetFormData("form_id" & indexn),0)
					     form_extendflag(indexn) = 0
				case else
					     form_type(indexn) = 999
					     form_id(indexn) = 0
					     form_extendflag(indexn) = 0
			end select
			form_id(indexn) = FormClass_CheckFormValue(form_id(indexn),"","int",0,"",0)
			form_extendflag(indexn) = FormClass_CheckFormValue(form_extendflag(indexn),"","int",0,"",0)
			form_title(indexn) = lefttrue(GetFormData("form_title" & indexn),1024)
			form_listnum(indexn) = GetFormData("form_listnum" & indexn)
			form_listnum(indexn) = FormClass_CheckFormValue(form_listnum(indexn),"","int",0,"",0)
			
			
			form_style(indexn) = 0
			Temp2 = 1
			For TempN = 0 to Ubound(StyleItem,1)
				N = Request("form_style" & indexn & TempN+1)
				If N <> "1" Then N = "0"
				If N = "1" Then form_style(indexn) = form_style(indexn)+cCur(Temp2)
				Temp2 = Temp2*2
			Next
	
			form_title(indexn) = replace(form_title(indexn),"<" & "%","")
			form_title(indexn) = replace(form_title(indexn),"%" & ">","")
			form_title(indexn) = replace(form_title(indexn),"<" & "script","")
			form_title(indexn) = replace(form_title(indexn),"</" & "script","")
			form_title(indexn) = replace(form_title(indexn),chr(10),"")
			form_title(indexn) = replace(form_title(indexn),chr(13),"")
			form_title(indexn) = replace(form_title(indexn),"#~#^#","")
			if indexn > 0 then form_content = form_content & VbCrLf
			form_content = form_content & form_type(indexn) & "#~#^#" & form_title(indexn) & "#~#^#" & form_listnum(indexn) & "#~#^#" & form_id(indexn) & "#~#^#" & form_extendflag(indexn) & "#~#^#" & form_style(indexn)
		next

		private_Saveformdata()
		CALL Update_InsertSetupRID(1051,"article/" & FileName,8,form_content," and ClassNum=" & 8)

	End Sub

	private sub private_Saveformdata

		Call ADODB_SaveToFile(form_content,FileName)
		Response.Write "<span class=cms_ok>成功编辑首页栏目信息.</span>"

	End Sub
	
	private sub private_getinfo
	
		dim rs,sql
		sql  = "select top 1 t1.saveData,t2.classname from leadbbs_setup as t1 left join article_newsclass as T2 on t1.classNum=t2.id where t1.rid=1052 and t1.classNum=" & form_fileid
		set rs = ldexecute(sql,0)
		if not rs.eof then
			form_content = rs(0)
			form_classname = rs(1)&""
		end if
		rs.close
		set rs = nothing
		if form_classname = "" then
			sql = "select top 1 classname from article_newsclass where id=" & form_fileid
			set rs = ldexecute(sql,0)
			if not rs.eof then
				form_classname = rs(0)
			end if
			rs.close
			set rs = nothing
			if form_classname = "" then form_classname = "首页"
		end if

	end sub

	private function private_getClassinfo

		if form_content = "" then form_content = ADODB_LoadFile(FileName)
		dim tmp,n,tmp2
		tmp = SplitLines(form_content)   ' §36: the data file is LF-only, Split(...,VbCrLf) collapses it
		for n = 0 to ubound(tmp)
			tmp2 = split(tmp(n),"#~#^#")
			form_style(n) = 0
			if ubound(tmp2) >= 4 then
				form_type(n) = tmp2(0)
				form_title(n) = tmp2(1)
				form_listnum(n) = tmp2(2)
				form_id(n) = tmp2(3)
				form_extendflag(n) = tmp2(4)
				if ubound(tmp2) >= 5 then form_style(n) = tmp2(5)
			else
				form_type(n) = 999
				form_title(n) = "null"
				form_listnum(n) = 0
				form_id(n) = 0
				form_extendflag(n) = 0
			end if
		next
		
	end function
	
	Public Sub center_Class_Form
	%>
	<div id=testttt></div>
		<script>
		$(document).ready(function(){
		$("select.itemtype").combobox({
		onChange: function (n,o){
		checkselect(this);
		//alert($(this).change);
		}
		});
		}); 

		function checkselect(obj,clickflag)
		{
			var sel = $(obj).parent().parent();
			var numitem = $(sel).next(".itemline").next(".itemline").next(".itemline").find('.itemtitle');
			if(clickflag!=-1){
			}
			switch($(obj).combobox('getValue'))
			{
				case "999":
					$(sel).next(".itemline").hide().next(".itemline").hide().next(".itemline").hide().next(".itemline").hide().next(".itemline").hide();
					$(numitem).html("相关编号");
					break;
				case "0":
					$(sel).next(".itemline").show().next(".itemline").show().next(".itemline").hide().next(".itemline").hide().next(".itemline").show();
					$(numitem).html("相关编号");
					break;
				case "1":
					$(sel).next(".itemline").show().next(".itemline").show().next(".itemline").hide().next(".itemline").hide().next(".itemline").show();
					$(numitem).html("相关编号");
					break;
				case "2":
					$(sel).next(".itemline").show().next(".itemline").show().next(".itemline").show().next(".itemline").hide().next(".itemline").show();
					$(numitem).html("专题编号");
					if(clickflag!=-1)
					{
					var index = $(obj).attr("comboname").replace(/form_type/,"");
					$('#form_id'+index).combobox('reload', '<%=DEF_BBS_HomeUrl%>inc/inchtm/data_goodassort.asp')
					}
					break;
				case "3":
					$(sel).next(".itemline").show().next(".itemline").show().next(".itemline").show().next(".itemline").show().next(".itemline").show();
					$(numitem).html("版块编号");
					if(clickflag!=-1)
					{
					var index = $(obj).attr("comboname").replace(/form_type/,"");
					$('#form_id'+index).combobox('reload', '<%=DEF_BBS_HomeUrl%>inc/inchtm/data_boardlist.asp?1')
					}
					break;
				case "4":
					$(sel).next(".itemline").show().next(".itemline").show().next(".itemline").show().next(".itemline").hide().next(".itemline").show();
					$(numitem).html("文章分类编号");
					if(clickflag!=-1)
					{
					var index = $(obj).attr("comboname").replace(/form_type/,"");
					$('#form_id'+index).combobox('reload', '<%=DEF_BBS_HomeUrl%>inc/inchtm/data_artileclass.asp')
					}
					break;
				case "5":					
					$(sel).next(".itemline").show().next(".itemline").hide().next(".itemline").show().next(".itemline").hide().next(".itemline").hide();
					$(numitem).html("文章ID");
					if(clickflag!=-1)
					{
					var index = $(obj).attr("comboname").replace(/form_type/,"");
					$('#form_id'+index).combobox('reload', '<%=DEF_BBS_HomeUrl%>article/inc/cache/data_blank.asp')
					}
					break;
				default:					
			}
		}
		function initItem()
		{
			//return;
			var arr = $(".itemline select.itemtype");
			for(var n=0;n<arr.length;n++)
			{
			checkselect(arr[n],-1);
			}
		}
		$(document).ready(function() {initItem();});
		function formatItem(row){
			if(row.id==0)
			return('<span style="font-weight:bold" class="grayfont">' + row.text + '</span>');
			else
			return(row.text);
		}
		</script>
		<b>说明: </b>
		<ol>
		<li>专题或版面编号：若栏目类型为专题，则此项请填写专题编号，如果为版面，请填写版面编号，若为文章，请填写相应的文章分类编号。否则可以忽略</li>
		<li>更多选项：此项只有当栏目类型为版面时才有效</li>
		</ol>
		<hr class=splitline>
		<div class="definehome">
		<%
		dim n
		CALL FormClass_Head(Form_ActionStr & " - " & form_classname,0,"center.asp?action=setchannel")
		CALL FormClass_ItemPring("","hidden","form_fileid",form_fileid,"","","","","")
		CALL FormClass_ItemPring("","hidden","submitflag","yes","","","","","")
		
		dim str,datafile,arr
		for n = 0 to 15
			response.Write "<div class='itemline'><span class='iteminfo'><b>栏目" & n+1 & "</b></span></div>"
			CALL FormClass_ItemPring("类型","select","form_type" & n,form_type(n),"","","","999~~~无-关闭此栏|0~~~列出论坛最新主题|1~~~列出论坛最新精华|2~~~列出某(版面)专题帖子|3~~~列出某一个版面的帖子|4~~~列出某文章分类下的文章|5~~~展示单个文章内容(须HTML格式内容)"," class=""easyui-combobox itemtype""")
			if form_title(n) = "null" then form_title(n) = ""
			CALL FormClass_ItemPring("名称","input","form_title" & n,form_title(n),4,255,"为此项栏目列表起个标题,可以为空","","")
			CALL FormClass_ItemPring("显示数量","input","form_listnum" & n,form_listnum(n),2,2,"此栏目显示的最大记录条数","","")
			'CALL FormClass_ItemPring("相关编号","input","form_id" & n,form_id(n),2,12,"","","")
			
			select case form_type(n)
				case 2:
					datafile = "data_goodassort.asp"
				case 3:
					datafile = "data_boardlist.asp"
				case 4:
					datafile = "data_artileclass.asp"
			end select
			str = "<input class=""easyui-combobox"" id=""form_id" & n & """ name=""form_id" & n & """ value=""" & form_id(n) & """ data-options=""" & VbCrLf &_
					"	url: '" & DEF_BBS_HomeUrl & "inc/inchtm/" & datafile & "'," & VbCrLf &_
					"	valueField: 'id'," & VbCrLf &_
					"	textField: 'text'," & VbCrLf &_
					"	panelWidth: 250," & VbCrLf &_
					"	panelHeight: 'auto'," & VbCrLf &_
					"	formatter: formatItem" & VbCrLf &_
					""">" & VbCrLf
			'str = "<input class=""easyui-combobox"" id=""form_id" & n & """ name=""form_id" & n & """ data-options=""valueField:'id',textField:'text'"">"
			CALL FormClass_ItemPring("相关编号","other",str,form_id(n),2,12,"","","")
			CALL FormClass_ItemPring("更多选项","select","form_extendflag" & n,form_extendflag(n),"","","","0~~~版块最新主题帖|1~~~版块最新精华帖"," class=""easyui-combobox""")
			CALL FormClass_ItemPring("定制界面","splitchecked","form_style" & n,form_style(n),"","","",StyleItem,"")
			response.Write "<div class='itemline'><span class='iteminfo'><hr class=""splitline"" /></span></div>"
		next
		Call FormClass_End()
		%>
		</div>
		<br /><br />
		<%
	
	End Sub
	
End Class

%>