	<script type="text/javascript">
	<!--
	function surfto1(list)
	{
		var myindex1  = list.selectedIndex;
		if (myindex1 != 0)
		{
			var URL = "../" + list.options[list.selectedIndex].value;
			this.location.href = URL; 
			target = '_self';
		}
	}
	-->
	</script>
	<select name="jumpto" onchange="surfto1(this)" style="width:100px;">
		<option value="boards.asp">切换版面…</option>
		<option value="boards.asp">论坛首页</option>
		<option value="boards.asp?assort=1">＋论坛主区</option>
		<option value="b/b.asp?b=100&page=1">　测试专区</option>
		<option value="b/b.asp?b=444&page=1">　回收站</option>
	</select>
