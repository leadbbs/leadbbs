<!-- #include file=../../inc/BBSsetup.asp -->
<table border=0 cellspacing=0 unselectable=on style="cursor: move;padding:5px 0px 5px 0px;" onmousedown="LD.move.mousedown(this.parentNode,event);">
<tr><td align=right unselectable=on>
<div class="layer_close"><a href="javascript:;" onclick="LD.hide('editor_insttable');return false;" class="unsel" hidefocus="true" title="close" /></a></div>
</td></tr>
<tr>
	<td>
	<fieldset unselectable=on>
	<legend unselectable=on>表格大小</legend>
	<table border=0 cellpadding=5 cellspacing=0 unselectable=on>
	<tr>
	<td noWrap unselectable=on>
		行数
		</td><td unselectable=on><input type=text id=d_row size=5 value="" onkeypress="event.returnValue=IsDigit(event);" maxlength=3 class="fminpt input_1">
		</td><td noWrap unselectable=on>列数
		</td><td unselectable=on><input type=text id=d_col size=5 value="" onkeypress="event.returnValue=IsDigit(event);" maxlength=3 class="fminpt input_1">
		</td><td noWrap unselectable=on>背景
		</td><td unselectable=on><input type=text id="d_bgurl" style="width:98px" size=13 value="" class="fminpt input_2">
	</td>
	</tr>
	</table>
	</fieldset>
	</td>
</tr>
<tr>
	<td>
	<fieldset>
	<legend>表格布局</legend>
	<table border=0 cellpadding=5 cellspacing=0>
	<tr>
	<td>
		对齐方式:
		<select id="d_align">
			<option value=''>默认</option>
			<option value='left'>左对齐</option>
			<option value='center'>居中</option>
			<option value='right'>右对齐</option>
			</select>
		边框粗细:
		<input type=text id=d_border size=10 value="" onkeypress="event.returnValue=IsDigit(event);" class="fminpt input_1">
	</td>
	</tr>
	<tr>
		<td>单元间距:
		<input type=text id=d_cellspacing size=10 value="" onkeypress="event.returnValue=IsDigit(event);" maxlength=3 class="fminpt input_1">
		单元边距:
		<input type=text id=d_cellpadding size=10 value="" onkeypress="event.returnValue=IsDigit(event);" maxlength=3 class="fminpt input_1">
	</td>
	</tr>
	</table>
	</fieldset>
	</td>
</tr>
<tr>
	<td>
	<fieldset>
	<legend>表格宽度</legend>
	<table border=0 cellpadding=5 cellspacing=0 width='100%'>
	<tr>
		<td><input id="d_check" type="checkbox" onclick="d_widthvalue.disabled=(!this.checked);d_widthunit.disabled=(!this.checked);" value="1" class="fmchkbox">指定表格的宽度
			<input name="d_widthvalue" id="d_widthvalue" type="text" value="" size="5" onkeypress="event.returnValue=IsDigit(event);" maxlength="4" class="fminpt input_1">
			<select name="d_widthunit" id="d_widthunit">
			<option value='px'>像素</option><option value='%'>百分比</option>
			</select>
		</td>
	</tr>
	</table>
	</fieldset>
	</td>
</tr>
<tr>
	<td>
	<fieldset>
	<legend>表格颜色</legend>
	<table border=0 cellpadding=0 cellspacing=0 style="padding:5px;">
	<tr>
		<td>边框颜色:
		<input type=text id=d_bordercolor size=7 value="" class="fminpt input_1">
		<a href=#ic onclick="editor_sAction = 'bordercolor';editor_view(this,'editor_selcolor','','selcolor.js');" class=ico>
		<img src="../images/blank.gif" class="a_pic" style="background-position:0px -198px;width:18px;height:17px;" style="cursor:pointer" align=absmiddle id=s_bordercolor></a>
		背景颜色:
		<input type=text id=d_bgcolor size=7 value="" class="fminpt input_1">
		<a href=#ic onclick="editor_sAction = 'bgcolor';editor_view(this,'editor_selcolor','','selcolor.js');" class=ico>
		<img src="../images/blank.gif" class="a_pic" style="background-position:0px -198px;width:18px;height:17px;" align=absmiddle id=s_bgcolor></a>
		</td>
	</tr>
	</table>
	</fieldset>
	</td>
</tr>
<tr><td align=right><a href=#inserttable class="clicktext" onclick="if(editor_insttablesubmit()==true)LD.hide('editor_insttable');">插入/更新表格</a></td></tr>
</table>