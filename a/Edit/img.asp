<!-- #include file=../../inc/BBSsetup.asp -->
<table border=0 cellpadding=0 cellspacing=0 style="cursor: move;" onmousedown="LD.move.mousedown(this.parentNode,event);">
<tr>
	<td style="padding:0px 0px 5px 0px;">
	<div align="right" style="width:100%;float:left">
	<div class="layer_close"><a href="javascript:;" onclick="LD.hide('editor_img');return false;" class="unsel" hidefocus="true" title="close" /></a></div>
	</div>
	<br>
	<fieldset>
	<legend>图片来源</legend>
	<table border=0 cellpadding=5 cellspacing=0>
	<tr>
		<td noWrap>网络地址:</td>
		<td><input type=text id="img_d_fromurl" style="width:243px" size=255 value="" class="fminpt input_3">
	</tr>
	</table>
	</fieldset>
	</td>
</tr>
<tr>
	<td style="padding:0px 0px 5px 0px;">
	<fieldset>
	<legend>显示效果</legend>
	<table border=0 cellpadding=5 cellspacing=0>
	<tr>
		<td noWrap>边框粗细:</td>
		<td><input type=text id=img_d_border size=10 value="" ONKEYPRESS="event.returnValue=IsDigit(event);" class="fminpt input_1"></td>
		<td noWrap>对齐方式:</td>
		<td>
			<select id=img_d_align>
			<option value='absmiddle' selected>绝对居中</option>
			<option value='left'>居左</option>
			<option value='right'>居右</option>
			<option value='top'>顶部</option>
			<option value='middle'>中部</option>
			<option value='bottom'>底部</option>
			<option value='absbottom'>绝对底部</option>
			<option value='baseline'>基线</option>
			<option value='texttop'>文本顶部</option>
			</select></td>
	</tr>
	</table>
	</fieldset>
	</td>
</tr>


<tr>
	<td style="padding:0px 0px 5px 0px;">
	<fieldset>
	<legend>图片大小</legend>
	<table border=0 cellpadding=5 cellspacing=0>
	<tr>
		<td noWrap>宽度:</td>
		<td><input type=text id=img_d_width size=10 value="" ONKEYPRESS="event.returnValue=IsDigit(event);" class="fminpt input_1"></td>
		<td noWrap>高度:</td>
		<td><input type=text id=img_d_height size=10 value="" ONKEYPRESS="event.returnValue=IsDigit(event);" class="fminpt input_1"></td>
	</tr>
	</table>
	</fieldset>
	</td>
</tr>

<tr><td align=right>
<span class="clicktext" onclick="if(editor_imgok()==true)LD.hide('editor_img');">确定</span>
</td></tr>
</table>