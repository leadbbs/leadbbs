<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/User_Setup.asp -->
<!-- #include file=../../inc/Board_popfun.asp -->
<!-- #include file=../inc/UserTopic.asp -->
<%
DEF_BBS_HomeUrl = "../../"

Main

Sub Main

	Select Case Left(Request.QueryString,3)
		Case else
			BBS_SiteHead DEF_SiteNameString & " - 帮助文档索引",0,"帮助文档索引"
			UserTopicTopInfo("help")
			Help_Index
	End Select
	UserTopicBottomInfo
	sitebottom

End Sub

Sub Help_Index%>

<div class=title>帮助文档索引</div>
<ol>
<li><a href=#001>网站用户常见问题解答</a></li>
<li><a href=#FullSearchHelp>全文检索使用帮助</a></li>
<li><a href=#003>建议浏览</a></li>
<li><a href=#004>关于浏览限制</a></li>
<li><a href=#005>论坛常见用户类别及<u><%=DEF_PointsName(9)%></u>一览表</a></li>
<li><a href=#006>论坛版面图例</a></li>
<li><a href=#007>论坛帖子图例</a></li>
<li><a href=#008>论坛功能及管理功能图例</a></li>
</ol>
<hr class=splitline>

<div class=title>网站用户常见问题解答</div>
<OL class=helpOL>
<li>
	为何要注册成为网站用户？
	<div class=value2>注册成为网站用户，可以完全享受本站提供的全部服务，并能够更好与本站的其<br>
	它用户进行更好的交流。</div>
</li>
<li>为什么我登录几次后就提示“登录太频，请稍休息后再登录或联系管理员! ”的提示？<br>
	<div class=value2>
	为了用户的安全，对用户连续错误登录次数进行了限制,用户可以在5分钟后就可以重新登录进来。如果有旁人在非法猜密码登录，目前使用着的用户能够照样正常使用帐号。
	</div>
</li>
<li>用户<%=DEF_PointsName(0)%>是如何计算的？
<div class=value2><%=DEF_PointsName(0)%>来源有以下几个方面：</div>
	<div class=value2>论坛发表一篇主题帖子，加<%=DEF_BBS_AnnouncePoints*2%><%=DEF_PointsName(0)%><br>
  	论坛发表一篇回复帖子，加<%=DEF_BBS_AnnouncePoints%><%=DEF_PointsName(0)%><br>
	论坛一篇帖子成为精华帖，继续加<%=DEF_BBS_MakeGoodAnnouncePoints%><%=DEF_PointsName(0)%>
	</div>
<li>
	<a name=#UserLevel>用户<%=DEF_PointsName(3)%>列表</a>
	<div class=value2>
<table border="0" cellspacing="0" cellpadding="0" class=table_in>
  <tr>
    <td>
        <tr class=tbinhead> 
          <td><div class=value><%=DEF_PointsName(3)%></div></td>
          <td><div class=value>身份</div></td>
          <td><div class=value>发帖量</div></td>
          <td><div class=value>图示</div></td>
        </tr>
        <%Dim N
        For N = 1 to DEF_UserLevelNum%>
        <tr>
          <td class=tdbox><%=N%>级</td>
          <td class=tdbox><%=DEF_UserLevelString(N)%></td>
          <td class=tdbox><%=DEF_UserLevelPoints(N)%></td>
          <td class=tdbox><img src=../../images/<%=GBL_DefineImage%>lvstar/level<%=N%>.gif height=11 width=110></td>
        </tr><%Next%>
      </table>
      </div>
</ol>
<a name="FullSearchHelp"><div class=title>全文检索使用帮助</div></a>

                        <p><b>基本搜索</b></P>
                        <ul>
                        <p>检索简洁方便，仅需要按要求输入查询内容并敲一下回车键，即可开始查询。</P>
                        <p>检索严谨认真，对查询要求“一字不差”例如：对“应用”的搜索和“使用”的<br>
                        搜索，会出现不同的结果，因此在搜索时，您可以试用不同的关键词，但是，检<br>
                        索不区分大小写，例如检索“ASP”和“aSP”是没有区别的。
                        </ul>
                        
                        <p><b>AND的使用</b></P>
                        <ul>
                        <p>在检索时不需要使用"and"，检索系统自动会在关键词之间自动添加"AND"。提供<br>
                        符合您全部查询条件的记录。如果您想逐步缩小您的搜索范围，只需输入更多的<br>
                        关键词。
                        <p>例如：想检索既包含有“SQL”又有“语句”，只需键入“SQL 语句”即可，然后<br>
                        单击搜索按钮，而不必输入“SQL and 语句”。<br>
                        </P>
                        </ul>
                        <p><b>如何缩小搜索范围?</b></P>
                        <ul>
                          <p>有时查询会得到过多的结果。为得到最实用的资料，您需要进一步缩小查<br>
                          询。您只要输入更多的关键词筛选查询出来的资料，即可缩小搜索范围。</P>
                        </ul>
                        <p><b>“OR”或“AND”是否有效?</b></P>
                        <ul>
                          <p>在检索中既不使用“AND”也不使用“OR”。由于不支持“OR”搜索,所以检<br>
                          索时无法接受“或者包含词语A，或者包含词语B”的记录。如：您要查询“<br>
                          SQL”或“Oracle”，就必须分两次查询分别查询“SQL”和“Oracle”。</P>
                        </ul>
                        <p><b>忽略词语</b></P>
                        <ul>
                          <p>通常，我们会忽略<EM>“我”</EM>和<EM>“的”</EM>等太常见而又无太多意义的字符，以及数<br>
                          字和单字母及一些字符。</P>
                        </ul>
                        <p><b>为什么有的查询结果记录数不明确？</b></P>
                        <ul>
                          <p>为了提供查询速度，只提供符合记录的前面一部分供查询，对总查询结果的<br>
                          记录也只作估计处理。</P>
                        </ul>
                      <a name=003><div class=title>建议浏览</div></a>
                      <br>浏览器最低要求:<br>
                        <ul>
                          <li>若您的浏览器是IE内核，至少Internet Explorer 6.0+，若想获得基础的体验，至少需要IE8.0+</li>
                        </ul>
                        建议浏览:<br>
                        <ul><li>
                          Firefox，Chrome，Internet Explorer 11.0，Safari，Opera</li>
                          <br>
                          为了更好地保护您的隐私信息和浏览及操作安全、完全正常使用本站功能，<br>
                          建议您使用各标准浏览器最新版本。</li>
                        </ul>
                        <p>
                        建议屏幕分辨率
                        <ul>
                          1440 x 900 及以上
                        </ul>
                        <p>自动转换图像功能所支持的图像格式<p>
                        <ul>
                         jpg gif png
                        </ul>
                        <a name=code></a><b><font color=red class=redfont>什么是验证码？</font></b>
                        <ol><li>验证码要求用户发贴或其它认证时，需要输入页面中用图片显示的字符串。
				<li>附加码是为了避免不良用户使用程序对论坛进行灌水和发布垃圾广告，而提供的功能，使用户得到更安全的服务。
				<li>用户不用记忆附加码，附加码只对当次服务有效，不能重复使用。
						</ol>
                        <p>
                        <a name=lmt></a><b><a name=004><div class=title>关于浏览限制</div></a></b>
                        <ul>
                        因某些原因，论坛可能会对一些版面及帖子内容进行了特殊的限制<p>
                        <b>版面限制有以下几种情况：</b><p>
                        <ol>
                        <li>只有登录用户才能访问：必须<a href=../<%=DEF_RegisterFile%>>注册</a>成为论坛用户并正常<a href=../login.asp>登录</a>后才能浏览
                        <li>只对<%=DEF_PointsName(8)%>以上开放：只有<%=DEF_PointsName(8)%>才能浏览的版面，一般是<%=DEF_PointsName(8)%>交流专用版面
                        <li>只对<%=DEF_PointsName(5)%>开放：论坛用户分普通与<%=DEF_PointsName(5)%>，用户认证需要经管理员审核指定
                        <li>保密论坛：在进入之前，每个用户必须输入相应的密码(有的还须输入验证码)，密码由管理员提供
                        <li>论坛如果有开放论坛，则允许游客直接发表与回复帖子
                        <li>限时关闭论坛：此类版面有时限性，在显示的时间里，呈关闭状态。
                        <li>此帖有待管理人员审核才能查看：此类帖子需要管理人员审核(开放)通过才能查看
                        <li>版面更多限制：需要用户符合特定状态才能访问
                        </ol>
                        
                        <br><b>帖子主题内容限制有以下几种情况：</b><p>
                        <ol>
                        <li>查看本帖需要一定<%=DEF_PointsName(0)%>：<%=DEF_PointsName(0)%>一般由发表帖子或其它途径获得，旨在为论坛提高人气。查看只需要达到一定<%=DEF_PointsName(0)%>，并不消耗<%=DEF_PointsName(0)%>值
                        <li>查看本帖需要一定<%=DEF_PointsName(4)%>：<%=DEF_PointsName(4)%>根据登录后的用户，依在线时间来计算，一分钟增加<%=DEF_PointsName(4)%>1，是衡量用户呆在论坛时间的标准。查看帖子后并不消耗<%=DEF_PointsName(4)%>值
                        <li>购买此帖需要消耗<%=DEF_PointsName(0)%>：查看这样的帖子，首先必须是登录后的用户，并需要所显示的<%=DEF_PointsName(0)%>值，点击购买，系统将把你的相应<%=DEF_PointsName(0)%>点数转移给发帖人。购买后，将可以正常看到帖子内容。
                        <li>仅本版<%=DEF_PointsName(8)%>才能查看：此类帖子仅允许此版<%=DEF_PointsName(8)%>或<%=DEF_PointsName(6)%>以上的管理员人员查看。
                        <li>仅<%=DEF_PointsName(8)%>才能查看：此类帖子只有<%=DEF_PointsName(8)%>以上权限的用户才能查看。
                        <li>仅<%=DEF_PointsName(5)%>才能查看：查看此类帖子必须先成为论坛的<%=DEF_PointsName(5)%>。论坛用户分普通与认证用户，用户认证需要经管理员审核指定。
                        </ol>
                        <p>
                        <a name=lmt></a><a name=005><div class=title>论坛常见用户类别及<%=DEF_PointsName(9)%>一览表</div></a>
                        <br>
                        <ol>
                        <li>普通用户：拥有浏览论坛，发表帖子和短消息等基本的权限</li>
                        <li>非正式用户：只拥有浏览论坛的权限，而无权限发表帖子和发送短消息，投票等操作</li>
                        <li><%=DEF_PointsName(5)%>：拥有进入某些认证版块的特殊权限</li>
                        <li><%=DEF_PointsName(8)%>：拥有对所担任版面维护权限</li>
                        <li><%=DEF_PointsName(6)%>：拥有全部版面维护，总固顶主题等权限，或其它扩展权限</li>
                        <li><%=DEF_PointsName(9)%>一览表：
                        	<ul>
				<%
				For N = 1 to DEF_UserOfficerNum
					Response.Write "<li>编号" & N & "：" & DEF_UserOfficerString(N) & "</li>" & VbCrLf
				Next
				%>
                        	</ul>
                        </li>
                        </ol>

                        <p>
                        <a name=lmt></a><a name=006><div class=title>论坛版面图例</div></a>
                        <br>
                        <ul>
                        <div class=b_new><br>有新帖的版面<br><br></div>
                        <br>
                        <div class=b_none><br>无新帖的版面<br><br></div>
                        </ul>

                        <p>
                        <a name=lmt></a><a name=007><div class=title>论坛帖子图例</div></a>
                        <br>
                        <ul>
                        <img src=../../images/<%=GBL_DefineImage%>state/alltop.gif align=absmiddle>
                        总固顶的帖子，任何版面可见帖
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>state/parttop.gif align=absmiddle>
                        区固顶的帖子，处于总固顶帖之下固顶帖之上，仅在当前分区有效
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>state/intop.gif align=absmiddle>
                        固顶的帖子，永远固定在版面的首页顶端位置
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>state/vt.gif align=absmiddle>
                        投票帖
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>state/tpcnew.gif align=absmiddle>
                        新主题
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>state/hot.gif align=absmiddle>
                        热门帖子
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>state/tpc.gif align=absmiddle>
                        普通帖子
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>state/lock.gif align=absmiddle>
                        锁定的帖子
                        <p>
                        </ul>
                        

                        <p>
                        <a name=lmt></a><a name=008><div class=title>论坛功能及管理功能图例</div></a>
                        <br>
                        <ul>
                        <img src=../../images/<%=GBL_DefineImage%>home.gif align=absmiddle>
                        查看帖子作者的网站主页
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>mail.gif align=absmiddle>
                        给帖子作者发送邮件(使用邮件发送软件)
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>re.gif align=absmiddle>
                        引用此帖子的部分内容进行回复
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>message.gif align=absmiddle>
                        给帖子作者发送论坛短消息
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>edit.gif align=absmiddle>
                        编辑论坛帖子内容
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>ts.gif align=absmiddle>
                        自动排版消除多余换行 管理人员还可以用它锁定帖子，审核帖子
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>friend.gif align=absmiddle>
                        加此用户成为我的论坛好友
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>collect.gif align=absmiddle>
                        收藏论坛主题
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>del.gif align=absmiddle>
                        删除此帖子或投入回收站
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>jh.gif align=absmiddle>
                        精华一个主题或取消精华，奖惩发帖用户
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>ti.gif align=absmiddle>
                        提取主题到所在版面的最首位置
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>repair.gif align=absmiddle>
                        自动修复损坏了的主题
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>move.gif align=absmiddle>
                        转移此主题到其它的论坛版面
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>maketop.gif align=absmiddle>
                        将此主题成为固顶帖子或取消固顶
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>makeparttop.gif align=absmiddle>
                        将此主题成为区固顶帖子或取消区固顶
                        <p>
                        <img src=../../images/<%=GBL_DefineImage%>makealltop.gif align=absmiddle>
                        将此主题成为总固顶帖子或取消总固顶
                        <p>
                        </U>
                      </td>
                    </tr>
                       

                  </table>

<%End Sub%>