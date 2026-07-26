<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/UserTopic.asp"-->
<%
DEF_BBS_HomeUrl = "../../"

Main()

Sub Main

	Select Case Left(Request.ServerVariables("QUERY_STRING"),4)
		Case "icon"
			BBS_SiteHead DEF_SiteNameString & " - 论坛表情",0,"论坛表情"
			UserTopicTopInfo("help")
			Help_UbbIcon()
		Case "colo"
			BBS_SiteHead DEF_SiteNameString & " - 颜色表",0,"颜色表"
			UserTopicTopInfo("help")
			Help_UbbColor()
		Case else
			BBS_SiteHead DEF_SiteNameString & " - UBB代码释疑",0,"UBB代码释疑"
			UserTopicTopInfo("help")
			Help_UbbCode()
	End Select
	UserTopicBottomInfo()
	sitebottom()

End Sub

Function Help_UbbColor%>

<img src=<%=DEF_BBS_HomeUrl%>images/others/colortable.GIF>

<%End Function

Sub Help_UbbCode

	%>

<div class=title>什么是UBB代码？ </div>
<p>UBB代码是HTML的一个变种，是Ultimate Bulletin Board(国外的一个BBS程序)采用的一种特殊的TAG。您也许已经对它很熟悉了。UBB代码很简单，功能很少，但是由于其Tag语法检查实现非常容易，所以我们的网站引入了这种代码，以方便网友使用显示图片/联接/加粗字体等常见功能。 

<div class=title>UBB代码可以实现哪些HTML的功能，及它的使用例子和技巧？</div>
<OL class=helpOL>
<li>有两种方法可以加入超级连接，可以连接具体地址或者文字连接
<div class=value2><span class=redfont>[URL]</span><a href=http://www.%4c%65%61%64%42%42%53.%63%6f%6d/>http://www.asph.net/</a><span class=redfont>[/URL] 
  </span>
</div>
<div class=value2>[URL=</span><a href=http://%4c%65%61%64%42%42%53.%63%6f%6d/>http://www.asph.net/</a><span class=redfont>]</span>LeadBBS<span class=redfont>[/URL]</span>
</div>
<li>显示为粗体效果
<div class=value2><span class=redfont>[B]</span>文字<span class=redfont>[/B]</span></div>
<li>显示为斜体效果
<div class=value2><span class=redfont>[I]</span>文字<span class=redfont>[/I]</span></div>
<li>显示为下划线效果
<div class=value2><span class=redfont>[U]</span>文字<span class=redfont>[/U]</span></div>
<li>文字位置控制
<p>在文字的位置可以任意加入您需要的字符，<span class=bluefont>center</span>位置<span class=redfont>center</span>表示居中，<span class=redfont>left</span>表示居左，<span class=redfont>right</span>表示居右，<span class=redfont>justify</span>表示两端对齐
<div class=value2><span class=redfont>[ALIGN=<span class=bluefont>center</span>]</span><br>
  文字段落<br>
  <span class=redfont>[/ALIGN]</span></div>
<li>字间距(行高)控制
<p>行高值可以是<span class=bluefont>normal</span>，或是具体的行高数值，比如<span class=bluefont>150%</span>，<span class=bluefont>1.5</span>，<span class=bluefont>24pt</span>
<div class=value2><span class=redfont>[LINE-HEIGHT=<span class=bluefont>150%</span>]</span>
  文字段落
  <span class=redfont>[/LINE-HEIGHT]</span></div>
<li>加入邮件连接有两种方法可以，可以连接具体地址或者文字连接<br>

<div class=value2><span class=redfont>[EMAIL]</span>webmaster@LeadBBS.com<span class=redfont>[/EMAIL] 
  </span></div>
<div class=value2><span class=redfont>[EMAIL=</span>webmaster@LeadBBS.com<span class=redfont>]</span>LeadBBS<span class=redfont>[/EMAIL]</span></div>
<li>插入图片
<div class=value2><span class=redfont>[IMG]</span>http://www.LeadBBS.com/images/flag.gif<span class=redfont>[/IMG]</span><br>

<br>插入图片，指定对齐方式及边框大小，对齐方式有 <span class=bluefont>absmiddle left right top middle<br> bottom absbottom baseline texttop</span><p>
<span class=redfont>[IMG=<span class=bluefont>2</span>,<span class=bluefont>center</span>]</span>http://www.LeadBBS.com/images/flag.gif<span class=redfont>[/IMG]</span><br>
<span class=redfont>[IMG=<span class=bluefont>2,对齐方式,高度,宽度</span>]</span>http://www.LeadBBS.com/images/flag.gif<span class=redfont>[/IMG]</span><br>

<li>插入MicroMedia的Flash
<div class=value2><span class=redfont>[Flash]</span>http://www.test.com/flag.swf<span class=redfont>[/Flash]</span></div>
<div class=value2><span class=redfont>[Flash=<span class=bluefont>宽度,高度</span>]</span>http://www.test.com/flag.swf<span class=redfont>[/Flash]</span></div>
<li>实现代码功能，能使UBB编码方式下也可以显示UBB代码
<div class=value2><span class=redfont>[CODE]<br>
  </span>文字段落<br>
  <span class=redfont>[/CODE]</span></div>
<li>引用效果，用表格框上
<div class=value2><span class=redfont>[QUOTE]</span><br>
  引用段落<br>
  <span class=redfont>[/QUOTE]</span></div>
<li>实现HTML目录效果
<div class=value2><span class=redfont>[UL]</span>文字<span class=redfont>[/UL]</span> - 
  相当于html中的&lt;UL&gt;功能，缩进排版<br>
  <span class=redfont>[OL]</span>文字<span class=redfont>[/OL]</span> 
  - 相当于html中的&lt;OL&gt;，产生用数字编号的效果<br>
  <span class=redfont>[LI]</span>文字<span class=redfont>[/LI]</span> 
  - 相当于html中的&lt;li&gt;，与以上标签联合使用
<li>实现文字飞翔效果(跑马灯)，相当于html中的&lt;marquee&gt;
<div class=value2><span class=redfont>[FLY]</span>文字<span class=redfont>[/FLY]</span></div>
<li>插入单元线
<div class=value2><span class=redfont>[HR]</span>
<li>实现文字发光特效，GLOW内属性依次为距离、颜色和边界大小
<div class=value2><span class=redfont>[GLOW=</span><span class=bluefont>1,RED,2</span><span class=redfont>]</span>文字<span class=redfont>[/GLOW]</span></div>
<li>实现文字阴影特效，SHADOW内属性依次为距离、颜色和边界大小
<div class=value2><span class=redfont>[SHADOW=</span><span class=bluefont>1,RED,2</span><span class=redfont>]</span>文字<span class=redfont>[/SHADOW]</span></div>
<li>实现文字颜色改变
<div class=value2><span class=redfont>[COLOR=</span><span class=bluefont>颜色</span><span class=redfont>]</span>文字<span class=redfont>[/COLOR]</span></div>
<li>实现文字大小改变
<div class=value2><span class=redfont>[SIZE=</span><span class=bluefont>数字1-9或CSS字体的尺寸定义串</span><span class=redfont>]</span>文字<span class=redfont>[/SIZE]</span></div>
<li>实现文字字体转换
<div class=value2><span class=redfont>[FACE=</span><span class=bluefont>字体</span><span class=redfont>]</span>文字<span class=redfont>[/FACE]</span></div>

<li>插入中划线
<div class=value2><span class=redfont>[STRIKE]</span>文字<span class=redfont>[/STRIKE]</span></div>

<li>插入RealPlayer格式的rm文件，中间的数字为宽度和长度
<div class=value2><span class=redfont>[RM=<span class=bluefont>宽度</span>,<span class=bluefont>高度</span>]</span>http://....<span class=redfont>[/RM]</span></div>

<li>插入为Midia Player格式的文件，中间的数字为宽度和长度
<div class=value2><span class=redfont>[MP=<span class=bluefont>宽度</span>,<span class=bluefont>高度</span>]</span>http://....<span class=redfont>[/MP]</span></div>

<li>上标文字
<div class=value2><span class=redfont>[sup]</span>文字<span class=redfont>[/sup]</span>，效果：LeadBBS<sup>2</sup>

<li>下标文字
<div class=value2><span class=redfont>[sub]</span>文字<span class=redfont>[/sub]</span>，效果：LeadBBS<sub>2</sub>

<li>指定文字颜色及背景颜色
<div class=value2><span class=redfont>[BGCOLOR=<span class=bluefont>背景颜色</span>]</span>文字<span class=redfont>[/BGCOLOR]</span><br>
<span class=redfont>[BGCOLOR=<span class=bluefont>背景颜色</span>,<span class=bluefont>文字颜色</span>]</span>文字<span class=redfont>[/BGCOLOR]</span></div>

<li>插入背景音乐
<div class=value2><span class=redfont>[SOUND]</span>背景音乐文件地址<span class=redfont>[/SOUND]</span></div>

<li>插入栏目框
<div class=value2><span class=redfont>[FIELDSET=<span class=bluefont>标题</span>]</span>内容<span class=redfont>[/FIELDSET]</span></div>

<li>逐字闪烁效果
<div class=value2><span class=redfont>[LIGHT]</span>闪烁文字<span class=redfont>[/LIGHT]</span></div>

<li>插入表格
<div class=value2><span class=redfont>[TABLE][TR][TD]</span>内容<span class=redfont>[/TD][/TR][/TABLE]</span></div>

<div class=value2>插入复杂的表格，8个参数必须指定完全</div>
<div class=value2><span class=redfont>[TABLE=<span class=bluefont>边框色</span>,<span class=bluefont>单元间距</span>,<span class=bluefont>单元边距</span>,<span class=bluefont>表格宽</span>,<span class=bluefont>对齐方式</span>,<span class=bluefont>背景色</span>,<span class=bluefont>边框粗细</span>,<span class=bluefont>背景图片</span>][TR][TD]</span>内容<span class=redfont>[/TD][/TR][/TABLE]</span></div>
<div class=value2>TD标签允许更多的定义：[TD=列,行,背景色]，背景色可指定，也可不指定</div>

<li>已编排格式，等同于HTML中的&lt;PRE&gt;标签
<div class=value2><span class=redfont>[PRE]</span>文字<span class=redfont>[/PRE]</span></div>

<li>插入带LRC歌词的歌曲
<div class=value2><span class=redfont>[LRC=<span class=bluefont>播放文件地址</span>]</span><span class=bluefont>LRC文件地址或LRC文件内容</span><span class=redfont>[/LRC]</span></div>

<li>插入折叠的内容
<div class=value2><span class=redfont>[collapse<span class=bluefont>=折叠提示信息(此项可选)</span>]</span><span class=bluefont>具体的折叠内容</span><span class=redfont>[/collapse]</span></div>

<%End Sub

Sub Help_UbbIcon

	Dim N
	%><div class=title>论坛表情</div>
	<br>
	<table border=0 cellpadding=0 cellspacing=0 class=blanktable>
	<tr>
		<td>编号</td>
		<td>表情</td>
		<td>代码</td>
	</tr><%
	For n = 0 to DEF_UBBiconNumber - 1
		%>
	<tr>
		<td><%=Right(" " & n + 1,2)%></td>
		<td><img src="<%=DEF_BBS_HomeUrl%>images/UBBicon/em<%=Right("0" & n + 1,2)%>.GIF" width=20 height=20 align=middle border=0></td>
		<td>[em<%=Right("0" & n + 1,2)%>]</td>
	</tr>
		<%
	Next
	%>
	</table>
	<%

End Sub%>