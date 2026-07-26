
var colortb={
// 是否有效颜色值
IsColor:function(color){
	var temp=color;
	if (temp=="") return true;
	if (temp.length!=7) return false;
	return (temp.search(/\#[a-fA-F0-9]{6}/) != -1);
},
sTitle:"",
color:"",
color2:"" ,
oSelection:null,
sel_obj:null,
edt_doc : $id('LEADEDT').contentWindow.document,
edt_win : $id('LEADEDT').contentWindow,

SelRGB:null,
DrRGB:"",
hexch :['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'],


// 返回有背景颜色属性的对象
GetParent:function (obj){
	while(obj!=null && obj.tagName!="TD" && obj.tagName!="TR" && obj.tagName!="TH" && obj.tagName!="table")
		obj=obj.parentElement;
	return obj;
},

// 返回标签名的选定控件
GetControl:function (obj, sTag){
	obj=obj.item(0);
	if (obj.tagName==sTag){
		return obj;
	}
	return null;
},

// 数值转为RGB16进制颜色格式
N2Color:function (c){
	c = c.toString(16);
	switch (c.length) {
	case 1:
		c = "0" + c + "0000"; 
		break;
	case 2:
		c = c + "0000";
		break;
	case 3:
		c = c.substring(1,3) + "0" + c.substring(0,1) + "00" ;
		break;
	case 4:
		c = c.substring(2,4) + c.substring(0,2) + "00" ;
		break;
	case 5:
		c = c.substring(3,5) + c.substring(1,3) + "0" + c.substring(0,1) ;
		break;
	case 6:
		c = c.substring(4,6) + c.substring(2,4) + c.substring(0,2) ;
		break;
	default:
		c = "";
	}
	return '#' + c;
},

ToHex:function (n) {	
	var h, l;

	n = Math.round(n);
	l = n % 16;
	h = Math.floor((n / 16)) % 16;
	return (this.hexch[h] + this.hexch[l]);
},

DoColor:function (c, l){
	var r, g, b;

	r = '0x' + c.substring(1, 3);
	g = '0x' + c.substring(3, 5);
	b = '0x' + c.substring(5, 7);

	if(l > 120){
		l = l - 120;

		r = (r * (120 - l) + 255 * l) / 120;
		g = (g * (120 - l) + 255 * l) / 120;
		b = (b * (120 - l) + 255 * l) / 120;
	}else{
		r = (r * l) / 120;
		g = (g * l) / 120;
		b = (b * l) / 120;
	}

	return '#' + this.ToHex(r) + this.ToHex(g) + this.ToHex(b);
},

EndColor:function (){
	var i;

	if(this.DrRGB != this.SelRGB){
		this.DrRGB = this.SelRGB;
		for(i = 0; i <= 30; i ++)
		$id('GrayTable').rows[i].bgColor = this.DoColor(this.SelRGB, 240 - i * 8);
	}
},

selcolor_done:function (color)
{
	if (!this.IsColor(color)){
		alert('无效的颜色值！');
		return;
	}

	switch (editor_sAction) {
		case "forecolor":
			addcontent(0,'color','/color',color) ;
			break;
		case "backcolor":
			if(Browser.ie)
			{
				if(!edt_mode)
				{
					//addcontent(2,'color','/color',this.color2);
					addcontent(2,'BackColor','',color);
				}
				else
				{
					addcontent(0,'bgcolor','/bgcolor',this.color2 + "," + color);
				}
			}
			else
			{
				if(!edt_mode)
				{
					addcontent(2,'hilitecolor','',color);
				}
				else
				{
					addcontent(0,'bgcolor','/bgcolor',this.color2 + "," + color);
				}
			}
			break;
		case "bgcolor":
			$id("d_bgcolor").value = color;
			$id("s_bgcolor").style.backgroundColor = color;
			break;
		case "bordercolor":
			$id("d_bordercolor").value = color;
			$id("s_bordercolor").style.backgroundColor = color;
			break;
		default:
			break;
	}
},


wc:function (r, g, b, n){
	r = ((r * 16 + r) * 3 * (15 - n) + 0x80 * n) / 15;
	g = ((g * 16 + g) * 3 * (15 - n) + 0x80 * n) / 15;
	b = ((b * 16 + b) * 3 * (15 - n) + 0x80 * n) / 15;

	return '<td bgcolor=#' + this.ToHex(r) + this.ToHex(g) + this.ToHex(b) + ' height=8 width=8 unselectable=on onclick="colortb.SelRGB = this.bgColor;colortb.EndColor();colortb.selcolor_done(colortb.SelRGB);"></td>';
},


// 默认显示值
inittable:function(){	
	switch (editor_sAction) {
	case "forecolor":	// 字体前景色
		this.sel_obj = "editor_selcolor";
		this.sTitle = "字体前景色";
		if(Browser.ie)
		{
			this.oSelection = this.edt_doc.selection.createRange();
			this.color = this.oSelection.queryCommandValue("ForeColor");
		}
		else
			this.oSelection = this.edt_win.getSelection();
		if (this.color) this.color = this.N2Color(this.color);
		break;
	case "backcolor":	// 字体背景色
		this.sel_obj = "editor_selcolor";
		this.sTitle = "字体背景色";
		if(Browser.ie)
		{this.oSelection = this.edt_doc.selection.createRange();
		this.color = this.oSelection.queryCommandValue("BackColor");
		this.color2 = this.oSelection.queryCommandValue("ForeColor");
		}
		if (this.color) this.color = this.N2Color(this.color);
		if (this.color2){this.color2 = this.N2Color(this.color2);}else{this.color2="#000000";}
		break;
	case "bordercolor":
	case "bgcolor":		// 对象背景色
		this.sel_obj = "editor_selcolor";
		this.sTitle = "对象背景色";
		break;
	default:
		break;
	}
	if (!this.color) this.color = "#000000";
	this.SelRGB = this.color;
	this.DrRGB = '';
	
	var cnum = [1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0];
	var wstr="";
	wstr+='<table border=0 cellPadding=0 style=\"cursor: move;\" onmousedown=\"LD.move.mousedown(this.parentNode,event);\"><tbody><tr><td><div id=selcolortitle unselectable=on>选择颜色</div>';
	wstr+='<table border=0 cellPadding=0 cellSpacing=0 id=ColorTable height=120 width=240 style="CURSOR: pointer">';
	
	for(i = 0; i < 16; i ++){
		wstr+='<tr>';
		for(j = 0; j < 30; j ++){
			n1 = j % 5;
			n2 = Math.floor(j / 5) * 3;
			n3 = n2 + 3;
	
			wstr+=this.wc((cnum[n3] * n1 + cnum[n2] * (5 - n1)),
			(cnum[n3 + 1] * n1 + cnum[n2 + 1] * (5 - n1)),
			(cnum[n3 + 2] * n1 + cnum[n2 + 2] * (5 - n1)), i);
		}
	
		wstr+='</tr>';
	}
	wstr+='<tbody></tbody></table></td>';
	wstr+='<td align=right unselectable=on><div class="layer_close"><a href="javascript:;" onclick="LD.hide(\'' + this.sel_obj + '\');return false;" class="unsel" hidefocus="true" title="close" /></a></div><br><table border=0 cellPadding=0 cellSpacing=0 id=GrayTable width=20 height=120 style="margin-left:10px;CURSOR: pointer;table-layout:fixed;">';
	for(i = 255; i >= 0; i -= 8.5)
	wstr+='<tr bgcolor=#' + this.ToHex(i) + this.ToHex(i) + this.ToHex(i) + '><td TITLE=' + Math.floor(i * 16 / 17) + ' height=4 width=20 unselectable=on onclick="colortb.SelRGB = this.parentNode.bgColor;colortb.selcolor_done(colortb.SelRGB);"></td></tr>';
	wstr+='<tbody></tbody></table></td></tr></tbody></table></center></div>';
	if($id(this.sel_obj))$id(this.sel_obj).innerHTML = wstr;
	}
};
colortb.inittable();