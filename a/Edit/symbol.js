var symbolmax = 11;
function symbol_cc(cardID){
	var obj;
	for (var i=1;i<symbolmax;i++){
		obj=$id("card"+i);
		obj.style.fontWeight="normal";
		obj.className="clicktext";
	}
	obj=$id("card"+cardID);
	obj.className="grayfont";

	for (var i=1;i<symbolmax;i++){
		obj=$id("content"+i);
		obj.style.display="none";
	}
	obj=$id("content"+cardID);
	obj.style.display="";
}

function symbol_ov(obj){
	$id('sym_preview').innerHTML=obj.innerHTML;
}

symbol_cc(1);

function init_symbol()
{
	for(var m=1;m<symbolmax;m++)
	{
		var obj = $("#content"+m+" td");
		var str = $(obj).html();
		$(obj).html("");
		for(var n=0;n<str.length;n++)
		$(obj).append("<a href=#icon class=symbol>"+str.charAt(n)+"</a>");
	}
	$(".symbol").click(function() {
		symbol_inst(this);
	});
	$(".symbol").hover(function() {
		symbol_ov(this);
	});
}
init_symbol();