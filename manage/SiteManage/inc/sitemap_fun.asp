<%
Class sitemap_main

	private s_count
	
	Private Sub Class_Initialize
	
		s_count = 0
		sitemap_page()
	
	End Sub
	
	private sub sitemap_page
	
		%>
		<div class="frameline">
		<%sitemap_siteinfo%>
		<%sitemap_form%>
		</div>
		<%
	
	end sub
	
	private sub sitemap_siteinfo
	
		dim rs,sql
		select case DEF_UsedDataBase
			case 1:
				sql = "select count(*) from leadbbs_topic"
			case else
				sql = "select count(*) from leadbbs_announce where parentid=0"
		end select
		set rs = ldexecute(sql,0)
		
		dim count : count = 0
		if not rs.eof then
			count = toNum(rs(0),0)
		end if
		rs.close
		set rs = nothing
		s_count = count
	
	end sub
	
	private sub sitemap_form
	
		%>约有<%=s_count%>帖子记录待成生，<a href="../BlockUpdate/UpdateUnderWritePrintColumn.asp?flag=UpdateRootMaxMinAnnounceID&BlockType=4">点此进入SiteMap生成页面</a><%
	
	end sub


End Class
%>