  
  String.prototype.trim = function()
			{
				// 用正则表达式将前后空格
				// 用空字符串替代。
				return this.replace(/(^\s*)|(\s*$)/g, "");
			}


			function StringToDate(DateString){
				
				var ls_Date=DateString;
				
				
				var r, re;
				var strQuote;
				
				re = / /i;            // 创建正则表达式模式。
   				r = ls_Date.search(re);            // 查找字符串。

				if (r==-1) {
					str_1=ls_Date;
				}else{
					var str_1=ls_Date.substr(0,r)
					var str_2=ls_Date.substr(r,ls_Date.length-r)
					str_2=str_2.trim();
					
					re = /:/g;      
	   				str_2 = str_2.replace(re, ",");
	   				strQuote = ",";
	   				var arrTime = str_2.split(strQuote);
				}
				
				re = /-/g;             
				str_1 = str_1.replace(re, ",");   

				re = /\//g;             
   				str_1 = str_1.replace(re, ",");

				strQuote = ",";
				
				var arrDate = str_1.split(strQuote);
				
				if (arrDate.length>2) {
					if (arrTime) 
					{
						if (arrTime.length==0)
						{
							var newDate=new Date(arrDate[0],arrDate[1],arrDate[2]);
						}
						if (arrTime.length==1)
						{
							var newDate=new Date(arrDate[0],arrDate[1],arrDate[2],arrTime[0]);
						}
						if (arrTime.length==2)
						{
							var newDate=new Date(arrDate[0],arrDate[1],arrDate[2],arrTime[0],arrTime[1]);
						}
						if (arrTime.length>2)
						{
							var newDate=new Date(arrDate[0],arrDate[1],arrDate[2],arrTime[0],arrTime[1],arrTime[2]);
						}
					}else{
						var newDate=new Date(arrDate[0],arrDate[1],arrDate[2])
					}
				}
				
				if (newDate) {
						if (isNaN(newDate)) {
							return false;
						}else{
							return newDate
						}
					}else{
						return false
					}

			}


			function IsDate(DateValue) {
				newDate=StringToDate(DateValue);
				if (newDate) {
					return true;
				}else{
					return false;
				}
			}
			
			
			function m_GetDateByDays2Now(Days2Now) {
				var now = new Date();
				return DateAdd("d", -Days2Now,now);
			}
			
			function DateAdd(timeU,byMany,dateObj) {
				var millisecond=1;
				var second=millisecond*1000;
				var minute=second*60;
				var hour=minute*60;
				var day=hour*24;
				var year=day*365;
			
				var newDate;
				var dVal=dateObj.valueOf();
				switch(timeU) {
					case "ms": newDate=new Date(dVal+millisecond*byMany); break;
					case "s": newDate=new Date(dVal+second*byMany); break;
					case "mi": newDate=new Date(dVal+minute*byMany); break;
					case "h": newDate=new Date(dVal+hour*byMany); break;
					case "d": newDate=new Date(dVal+day*byMany); break;
					case "y": newDate=new Date(dVal+year*byMany); break;
				}
				return newDate;
			}

			var gdCurDate = new Date();

			var giYear = gdCurDate.getFullYear();
			var giMonth = gdCurDate.getMonth()+1;

			var giDay = gdCurDate.getDate();

			var gdCtrl = new Object();
			var goSelectTag = new Array();
			var gcGray = "#808080";
			var gcToggle = "#ffff00";
			var gcBG = "#FFFFFF";
			var previousObject = null;

			var gdNowDate = new Date();
			var gNowYear = gdNowDate.getFullYear();
			var gNowMonth = gdNowDate.getMonth()+1;
			var gNowDay = gdNowDate.getDate();
			
			var gNiYear = 0;
			var gNiMonth = 0;
			var gNiDay = 0;

			var gCalMode = "";
			var gCalDefDate = "";

			var CAL_MODE_NOBLANK = "2";
			var last_ClickObj="";
			var last_CellFontColor="";
			var Flag_G2N="1";
			var Flag_N2G="";
			var dlg_BeginYear=1901
			
			function fSetDate(iYear, iMonth, iDay){
				if ((iYear == 0) && (iMonth == 0) && (iDay == 0)){
  					gdCtrl.value = "";
				}else{
  					iMonth = iMonth + 100 + "";
  					iMonth = iMonth.substring(1);
  					iDay   = iDay + 100 + "";
  					iDay   = iDay.substring(1);
  					gdCtrl.value = iYear+"-"+iMonth+"-"+iDay;
				}
				  
				for (i in goSelectTag)
  					goSelectTag[i].style.visibility = "visible";
				goSelectTag.length = 0;
				
				giYear = iYear;
				giMonth = iMonth;
				giDay = iDay;
				
				SetDays2Now(iYear, iMonth, iDay)
				
				if (Flag_N2G=="1") {
					Flag_G2N="1";
					Flag_N2G="";
				}else{
					Flag_G2N="1";

					var DataArray=G2N(iYear,iMonth,iDay)  
					gNiYear = DataArray[0];
					gNiMonth = DataArray[1];
					gNiDay = DataArray[2];
					set_N(DataArray[0],DataArray[1],DataArray[2])			
				}

			}

			function HiddenDiv()
				{
					var i;
				VicPopCal.style.visibility = "hidden";
				for (i in goSelectTag)
  					goSelectTag[i].style.visibility = "visible";
				goSelectTag.length = 0;

				}
			function fSetSelected(aCell){
				var iOffset = 0;
				var iYear = parseInt(getdocobj("tbSelYear").value);
				var iMonth = parseInt(getdocobj("tbSelMonth").value);
				
				with (aCell.children["cellText"]){
  					var iDay = parseInt(innerText);

  					if (color==gcGray)
						iOffset = (Victor<10)?-1:1;

					/*** below temp patch by maxiang ***/
					if( color == gcGray ){
						iOffset = (iDay < 15 )?1:-1;
					}
					/*** above temp patch by maxiang ***/

					iMonth += iOffset;
					if (iMonth<1) {
						iYear--;
						iMonth = 12;
					}else if (iMonth>12){
						iYear++;
						iMonth = 1;
					}
				}
				
				if (last_ClickObj!="") {
					last_ClickObj.style.backgroundColor = gcBG
					last_ClickObj.color=last_CellFontColor
				}
				
				last_ClickObj=aCell.children["cellText"]
				last_CellFontColor=aCell.children["cellText"].color
				
				aCell.children["cellText"].style.backgroundColor = "#0A246A";
				aCell.children["cellText"].color="#FFFFFF";
				
				giDay=iDay
				
				fSetDate(parseInt(iYear), parseInt(iMonth), parseInt(iDay));
			}

			function Point(iX, iY){
				this.x = iX;
				this.y = iY;
			}

			function fBuildCal(iYear, iMonth) {
			var aMonth=new Array();
			for(i=1;i<7;i++)
  				aMonth[i]=new Array(i);
			  
			var dCalDate=new Date(iYear, iMonth-1, 1);
			var iDayOfFirst=dCalDate.getDay();
			var iDaysInMonth=new Date(iYear, iMonth, 0).getDate();
			var iOffsetLast=new Date(iYear, iMonth-1, 0).getDate()-iDayOfFirst+1;
			var iDate = 1;
			var iNext = 1;

			for (d = 0; d < 7; d++)
				aMonth[1][d] = (d<iDayOfFirst)?-(iOffsetLast+d):iDate++;
			for (w = 2; w < 7; w++)
  				for (d = 0; d < 7; d++)
					aMonth[w][d] = (iDate<=iDaysInMonth)?iDate++:-(iNext++);
			return aMonth;
			}

			function fDrawCal(iYear, iMonth, iCellHeight, sDateTextSize) {
			var WeekDay = new Array("日","一","二","三","四","五","六");
			  
			var styleWeekTD = " bgcolor='"+gcBG+"' borderwidth='0' bordercolor='"+gcBG+"'  valign='middle' align='center' height='"+iCellHeight+"' style='font-size:9pt; BORDER-BOTTOM: #000000 1px solid;BORDER-LEFT: #000000 0px solid;BORDER-RIGHT: #000000 0px solid;BORDER-TOP: #000000 0px solid; ";
			var styleTD = " bgcolor='"+gcBG+"' borderwidth='0' bordercolor='"+gcBG+"'  valign='middle' align='center' height='"+iCellHeight+"' style='font-size:9pt; ";
			
			var ls_htmlstr = "";
			  	
			ls_htmlstr += ("<tr>");
			for(i=0; i<7; i++)
				ls_htmlstr += ("<td "+styleWeekTD+" color:#0A246A' >" + WeekDay[i] + "</td>");
			ls_htmlstr += ("</tr>");

  			for (w = 1; w < 7; w++) {
				ls_htmlstr += ("<tr>");
				for (d = 0; d < 7; d++) {
					ls_htmlstr += ("<td id=calCell "+styleTD+"cursor:hand;' onclick='fSetSelected(this)'>");
					ls_htmlstr += ("<font id=cellText ></font>");
					ls_htmlstr += ("</td>")
				}
				ls_htmlstr += ("</tr>");
			}
			
			
				return ls_htmlstr;
			}

			function fUpdateCal(iYear, iMonth) {
			myMonth = fBuildCal(iYear, iMonth);
			var i = 0;
			for (w = 0; w < 6; w++)
				for (d = 0; d < 7; d++)
					with (cellText[(7*w)+d]) {
						Victor = i++;
						if (myMonth[w+1][d]<0) {
							color = gcGray;
							innerText = -myMonth[w+1][d];
						}else{
							// Modified by maxiang for we need 
							// Saturday displayed in blue font color.
							//color = ((d==0)||(d==6))?"red":"black";
						
							style.backgroundColor=""
							if( d == 0 ){
								color = "red";
							}else if( d == 6 ){
								color = "blue";
							}else{
								color = "black";
							}
						
						
							var m_iMonthMaxDay=MonthMaxDay(parseInt(iYear),parseInt(iMonth))
							if (giDay>m_iMonthMaxDay) giDay=parseInt(m_iMonthMaxDay);
							
							if (giDay==myMonth[w+1][d]) {
								if (last_ClickObj!="") {
									last_ClickObj.style.backgroundColor = gcBG
									last_ClickObj.color=last_CellFontColor
								}
								
								last_ClickObj=cellText[(7*w)+d]
								last_CellFontColor= color
				
								style.backgroundColor="#0A246A"
								color="white";
								//alert(iMonth);
								
								//alert(giDay+"-maxday="+m_iMonthMaxDay)
								
								fSetDate(parseInt(iYear),parseInt(iMonth),parseInt(giDay));
							}
						
							// End of above maxiang
							innerText = myMonth[w+1][d];
						}
					}
			}
			
			function MonthMaxDay(m_iYear,m_iMonth){
				if (m_iMonth==2) {
					if (IsLeapYear(m_iYear)) 
						{
							return 29;
						}else{
							return 28;
						}
				}else{
					if (m_iMonth==1 || m_iMonth==3 ||  m_iMonth==5 || m_iMonth==7 || m_iMonth==8 || m_iMonth==10 ||  m_iMonth==12)
						{
							return 31;
						}else{
							return 30;
						}
				}
			}

			function getdocobj(id){
				return document.all[id];
			}
			function fSetYearMon(iYear, iMon){
			getdocobj("tbSelMonth").options[iMon-1].selected = true;
			for (i = 0; i < getdocobj("tbSelYear").length; i++)
				if (getdocobj("tbSelYear").options[i].value == iYear)
					getdocobj("tbSelYear").options[i].selected = true;
			fUpdateCal(iYear, iMon);
			}

			function fPrevMonth(){
			var iMon = getdocobj("tbSelMonth").value;
			var iYear = getdocobj("tbSelYear").value;
			  
			if (--iMon<1) {
				iMon = 12;
				iYear--;
			}
			  
			fSetYearMon(iYear, iMon);
			}

			function fNextMonth(){
			var iMon = getdocobj("tbSelMonth").value;
			var iYear = getdocobj("tbSelYear").value;
			  
			if (++iMon>12) {
				iMon = 1;
				iYear++;
			}
			  
			fSetYearMon(iYear, iMon);
			}

			function fToggleTags(){
			with (document.all.tags("SELECT")){
 				for (i=0; i<length; i++)
 					if ((item(i).Victor!="Won")&&fTagInBound(item(i))){
 						item(i).style.visibility = "hidden";
 						goSelectTag[goSelectTag.length] = item(i);
 					}
			}
			}

			function fTagInBound(aTag){
			with (VicPopCal.style){
  				var l = parseInt(left);
  				var t = parseInt(top);
  				var r = l+parseInt(width);
  				var b = t+parseInt(height);
				var ptLT = fGetXY(aTag);
				return !((ptLT.x>r)||(ptLT.x+aTag.offsetWidth<l)||(ptLT.y>b)||(ptLT.y+aTag.offsetHeight<t));
			}
			}

			function fGetXY(aTag){
			var oTmp = aTag;
			var pt = new Point(0,0);
			do {
  				pt.x += oTmp.offsetLeft;
  				pt.y += oTmp.offsetTop;
  				oTmp = oTmp.offsetParent;
			} while(oTmp.tagName!="BODY");
			return pt;
			}

			// Main: popCtrl is the widget beyond which you want this calendar to appear;
			//       dateCtrl is the widget into which you want to put the selected date.
			// i.e.: <input type="text" name="dc" style="text-align:center" readonly><input type="button" value="V" onclick="fPopCalendar(dc,dc);return false">
			var IsPanelDrawed = false;
			var IsDrawPanelActionStarted = false;
			function DrawCalender(popCtrl, dateCtrl, mode, defDate){
				if (!IsDrawPanelActionStarted) {
					drawcalendarpanel();	
				}
				
				if (!IsPanelDrawed) {
					window.setTimeout(DrawCalenderCell(popCtrl, dateCtrl, mode, defDate),1000);			
				}else
				{
					fPopCalendar(popCtrl, dateCtrl, mode, defDate)
				}
				
			}
			function fPopCalendar(popCtrl, dateCtrl, mode, defDate){
					gCalMode = mode;
					gCalDefDate = defDate;
				
					
					if (popCtrl == previousObject){
	  						if (VicPopCal.style.visibility == "visible"){
  							//HiddenDiv();
  							return true;
  						}
					  	
					}
					previousObject = popCtrl;
					gdCtrl = dateCtrl;
					fSetYearMon(giYear, giMonth); 
					var point = fGetXY(popCtrl);

						if( gCalMode == CAL_MODE_NOBLANK ){
							document.all.CAL_B_BLANK.style.visibility = "hidden";	
						}else{
							document.all.CAL_B_BLANK.style.visibility = "visible";
						}	

						with (VicPopCal.style) {
  							left = point.x;
							top  = point.y+popCtrl.offsetHeight;
							width = VicPopCal.offsetWidth;
							height = VicPopCal.offsetHeight;
							fToggleTags(point); 	
							visibility = 'visible';
						}
						setkeyevent();
					
				}

				var gMonths = new Array("1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月");

				function drawcalendarpanel() {
					var ls_htmlstr = "";
				
					
					ls_htmlstr += ("<div width='100%' style='background-color:#D4D0C8 '>")
					//----------阳历-------------
					ls_htmlstr += ("<FIELDSET width='100%'>")
					ls_htmlstr += ("<legend width='100%'><span style='font-size:9pt;'>阳历日期</span></legend>")
									
					ls_htmlstr += ("<Div id='VicPopCal' align='center' style='OVERFLOW:display;VISIBILITY:hidden;border:0px ridge;width:100%;height:100%;z-index:100;overflow:hidden'>");
					ls_htmlstr += ("<table width='150px' border='0' align='center' >");
					ls_htmlstr += ("<tr>");
					var obj_style=" style='font-size:9pt;  BORDER-BOTTOM: #000000 1px solid;BORDER-LEFT: #000000 1px solid;BORDER-RIGHT: #000000 1px solid;BORDER-TOP: #000000 1px solid; ' ";
					var obj_stylestr= "font-size:9pt;  BORDER-BOTTOM: #000000 1px solid;BORDER-LEFT: #000000 1px solid;BORDER-RIGHT: #000000 1px solid;BORDER-TOP: #000000 1px solid;";
					ls_htmlstr += ("<td valign='middle' align='center'><input type='button' "+obj_style+" name='PrevMonth' value='<' style='height:20;width:12;' onclick='fPrevMonth()'>");
					ls_htmlstr += ("&nbsp;<select name='tbSelYear' id='tbSelYear' style='width:70px;"+obj_stylestr+"' onChange='fUpdateCal(tbSelYear.value,tbSelMonth.value)' Victor='Won'>");
					for(i=dlg_BeginYear+1;i<2011;i++)
						ls_htmlstr += ("<option value='"+i+"'>"+i+"年</option>");
					ls_htmlstr += ("</select>");
					ls_htmlstr += ("<select name='tbSelMonth' id='tbSelMonth' style='width:50px;"+obj_stylestr+"' width='10' onChange='fUpdateCal(tbSelYear.value,tbSelMonth.value)' Victor='Won'>");
					for (i=0; i<12; i++)
						ls_htmlstr += ("<option value='"+(i+1)+"'>"+gMonths[i]+"</option>");
					ls_htmlstr += ("</select>");
					ls_htmlstr += ("&nbsp;<input type='button' "+obj_style+" name='PrevMonth' value='>' style='height:20;width:12;' onclick='fNextMonth()'>");
					ls_htmlstr += ("</td>");
					ls_htmlstr += ("</tr>");
					ls_htmlstr += ("<tr><TD colspan='7'><nobr><span style='font-size:9pt;'>和今天相距<input id=txt_Day2Now  style='width:50px;"+obj_stylestr+"' type=text maxLength=6 size=3 name=txt_Day2Now>天</span></nobr></td>");
					ls_htmlstr += ("</tr>");
					
					ls_htmlstr += ("<tr><td colspan='7' height='2'></td></tr>");
					ls_htmlstr += ("<tr><td align='center' colspan='2'>");
					ls_htmlstr += ("<div style='background-color:#FFFFFF'><table id='table_Calendar' width='100%' border='0' cellspacing='0' cellpadding='0'>");
					ls_htmlstr += fDrawCal(giYear, giMonth, 8, '9');
					ls_htmlstr += ("<tr><TD align='left' colspan='7'><nobr>");
					ls_htmlstr += ("<b ID=\"CAL_B_BLANK\" style='color:#000000; visibility:visible; cursor:hand; font-size:9pt' onclick='fSetDate(0,0,0)' onMouseOver='this.style.color=&quot;red&quot;' onMouseOut='this.style.color=&quot;#000000&quot;'></b>");
					ls_htmlstr += ("&nbsp;&nbsp;&nbsp;&nbsp;<b style='color:#000000;cursor:hand; font-size:9pt' onclick='NowDate(gNowYear,gNowMonth,gNowDay)' onMouseOver='this.style.color=&quot;red&quot;' onMouseOut='this.style.color=&quot;#000000&quot;'>今天: "+gNowYear+"-"+gNowMonth+"-"+gNowDay+"</b>");
					ls_htmlstr += ("</nobr></td></tr>");
					ls_htmlstr += ("</table></div>");
					ls_htmlstr += ("</td>");
					ls_htmlstr += ("</tr>");
					ls_htmlstr += ("<tr><td colspan='7' height='8'></td></tr>");
					ls_htmlstr += ("</table></Div>");
					ls_htmlstr += ("</FIELDSET>")
					//---------农历---------------
					ls_htmlstr += ("<FIELDSET width='100%'>")
					ls_htmlstr += ("<legend width='100%'><span style='font-size:9pt;'>农历日期</span></legend>")
					ls_htmlstr += ("<span style='font-size:9pt;'><input id=txt_NYear style='width:40px;"+obj_stylestr+"'   type=text maxLength=4 size=4 name=txt_NYear>年")
					ls_htmlstr += ("<input id=txt_NMonth  style='width:25px;"+obj_stylestr+"'  type=text maxLength=2 size=1 name=txt_NMonth  >月")
					ls_htmlstr += ("<input id=txt_NDay style='width:25px;"+obj_stylestr+"'   type=text maxLength=2 size=1 name=txt_NDay >日</span>")
					ls_htmlstr += ("<br><span id='span_N_String' style='font-size:9pt;'></span>")
					ls_htmlstr += ("</FIELDSET>")
					//write("<table  width='100%' height='30'><tr><td align='right' valign='bottom'><input id=btn_Close   type=button  name=btn_Close  value='关   闭' style='BACKGROUND-image: url(&quot;../../_IMG/btn_PlainBg.gif&quot;);border-left: 0 solid ; border-right:  0 ; border-top:  0; border-bottom:  0; width:75;height:21;' onclick='window.close()'></td></tr></table>")
					ls_htmlstr += ("</div>")
				
				
					$id("div_Calendar").innerHTML = ls_htmlstr;

					IsPanelDrawed = true;
					return true;
					
				}
			
			function Day2Now_Change(){
				var li_Day2Now=-(parseInt(getdocobj("txt_Day2Now").value))
				
				if (isNaN(li_Day2Now)) li_Day2Now=0;
				
				var flag_NullDay2Now
				if (getdocobj("txt_Day2Now").value=="") flag_NullDay2Now=1;
				
				var returndate= new Date(m_GetDateByDays2Now(li_Day2Now));
				
				var m_iYear=returndate.getFullYear()
				var m_iMonth=returndate.getMonth()+1 
				var m_iDay=returndate.getDate()
				
				set_G(m_iYear,m_iMonth,m_iDay)
				
				if (flag_NullDay2Now==1)  getdocobj("txt_Day2Now").value=""
				
			}
						
			function FromN2G(){
				niYear=parseInt(getdocobj("txt_NYear").value)
				if (getdocobj("txt_NYear").value.length>3) {
					niMonth=parseInt(getdocobj("txt_NMonth").value)
					niDay=parseInt(getdocobj("txt_NDay").value)
					if (isNaN(niYear)) niYear=gNiYear;
					if ((getdocobj("txt_NYear").value)=="") niYear=gNiYear;
					if (niYear<BeginYear+1) niYear=1901;
					if (niYear>2011) niYear=2011;
					
					if (isNaN(niMonth)) niMonth=gNiMonth;
					if ((getdocobj("txt_NMonth").value)=="") niMonth=1;
					if (niMonth>12) niMonth=12;
					if (niMonth<1) niMonth=1;
					
					if (isNaN(niDay)) niDay=gNiDay;
					if ((getdocobj("txt_NDay").value)=="") niDay=1;
					
					var MaxNMonthDay=NMonthMaxDay(niYear,niMonth);
					if (niDay>MaxNMonthDay) niDay=MaxNMonthDay;
					if (niDay<1) niMonth=1;
					
					if ((getdocobj("txt_NYear").value)!="") getdocobj("txt_NYear").value=niYear
					if ((getdocobj("txt_NMonth").value)!="")  getdocobj("txt_NMonth").value=niMonth
					if ((getdocobj("txt_NDay").value)!="")  getdocobj("txt_NDay").value=niDay
					
					var DataArray=N2G(niYear,niMonth,niDay)  
					
					Flag_N2G="1";
					
					giYear = DataArray[0];
					giMonth = DataArray[1];
					giDay = DataArray[2];
					
					window.document.all("span_N_String").innerHTML=YearAnimal(niYear)+"("+YearName(niYear)+")年"+ ((niMonth<0)?"闰":"") + c4[Math.abs(niMonth)-1] + "月" + c5[niDay-1]
					set_G(DataArray[0],DataArray[1],DataArray[2])
				}
			}
			
			function NowDate(m_iYear,m_iMonth,m_iDay) {
				giDay=m_iDay;
				fSetYearMon(m_iYear, m_iMonth)
			}
		
			function set_G(m_iYear,m_iMonth,m_iDay){
				giDay=m_iDay;
				fSetYearMon(m_iYear, m_iMonth)
			}
			
			function SetDays2Now(m_iYear,m_iMonth,m_iDay){
				getdocobj("txt_Day2Now").value=-parseInt(DaysBetweenDateAndNow(m_iYear,m_iMonth,m_iDay))

			}
			
			function set_N(niYear,niMonth,niDay){
				window.document.all("txt_NYear").value=niYear
				window.document.all("txt_NMonth").value=Math.abs(niMonth)
				window.document.all("txt_NDay").value=niDay
				window.document.all("span_N_String").innerHTML=YearAnimal(niYear)+"("+YearName(niYear)+")年"+ ((niMonth<0)?"闰":"") + c4[Math.abs(niMonth)-1] + "月" + c5[niDay-1]
			}
			
		
		
				
		var SMDay = new  Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
		var c1 = Array('甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸');
		var c2 = Array('子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥');
		var c3 = Array('鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪');
		var c4 = Array('正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二');
		var c5 = Array('初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
							'十一', '十二','十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
							'廿一', '廿二','廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
						);
		
		var BeginYear=1900
		var EndYear=2011
		
		
		var LongLife= new Array(
				'131198049', '132647038', '052586228', '133366046', '133477034', '041621224',
				'131386043', '132477032', '022746121', '132396040', '062651129', 
				'132637048', '133365036', '053365225', '132900044', '131386034', '022778122', //1918
				'132395041', '071175231', '131175050', '132635038', '052891127', '131701046', //12
				'131748035', '042741223', '130694043', '132391032', '021327122', '131175040', //18
				'061623129', '133402047', '133402036', '051769125', '131453044', '130694034', //24
				'032158223', '132350041', '073213230', '133221049', '133402038', '063466226', //30
				'132901045', '131130035', '042651224', '130605043', '132349032', '023371121', //36
				'132709040', '072901128', '131738047', '132901036', '051333226', '131210044', //42
				'132651033', '031111223', '131323042', '082714130', '133733048', '131706038', //48
				'062794127', '132741045', '131206035', '042734124', '132647043', '131318032', //54
				'033878120', '133477039', '071461129', '131386047', '132413036', '051245126', //60
				'131197045', '132637033', '043405122', '133365041', '083413130', '132900048', //66
				'132922037', '062394227', '132395046', '131179035', '042711124', '132635043', //72
				'102855132', '131701050', '131748039', '062804128', '132742047', '132359036', //78
				'051199126', '131175045', '131611034', '031866122', '133749040', '081717130', //84
				'131452049', '132742037', '052413127', '132350046', '133222035', '043477123', //90
				'133402042', '133493031', '021877121', '131386039', '072747128', '130605048', //96
				'132349037', '053243125', '132709044', '132890033' 
			);
			
			
			
			
		function IsLeapYear(LYear) {
			return  ((LYear%4 == 0)&&(( LYear%100 != 0)||(LYear%400 == 0))) ? true : false ;
		}
		
		function YearName(LYear){
			//1984甲子年
			var x, y, ya;
			
			ya = ((LYear-1984)%60<0) ? ((LYear-1984)%60 + 60) : (LYear-1984)%60  
			
			x = (ya%10);
			y = (ya%12);
			return c1[x] + c2[y];
		}
		
		function YearAnimal(LYear){
			//1984甲子年
			var y, ya;
			ya = (LYear-1984)%60<0 ? (LYear-1984)%60+60 : (LYear-1984)%60 
			y = (ya%12);
			return c3[y];
		}
		
		function Format_MonthStr(Str){
			if (Str.length<12) {
				for (i=Str.length;i<12;i++) {
					Str='0'+Str;
				}
			}
			return Str;
		}
		
		function NMonthMaxDay(niYear,niMonth){
			
			var  giYear,giMonth,giDay
			if (giYear<BeginYear || giYear>EndYear) return false;
			giYear=niYear;
			var y_Str=LongLife[giYear-BeginYear-1]
			
				
			var IsLYear=y_Str.substr(0,2)
			var MonType=parseInt(y_Str.substr(2,4),10).toString(2)
			
			MonType=Format_MonthStr(MonType)
			
			var li_DaysG2N=parseInt(y_Str.substr(7,2),10)
			
			var mothdays
			if (niMonth<0) {
				mothdays=(y_Str.substr(6,1)==2)?30:29 ;
			}else{
				mothdays=(MonType.substr((niMonth-1),1)==1)?30:29 ;
			}
			
			//alert(mothdays)
			return mothdays;
			
		}
		
		function G2N(giYear,giMonth,giDay){
			var niYear,niMonth,niDay
			if (giYear<BeginYear || giYear>EndYear) return false;
			niYear=giYear;
			var y_Str=LongLife[giYear-BeginYear-1]
			
			var IsLYear=y_Str.substr(0,2)
			var MonType=parseInt(y_Str.substr(2,4),10).toString(2)
			MonType=Format_MonthStr(MonType)
			
			var li_DaysG2N=parseInt(y_Str.substr(7,2),10)
			
			var li_Days_Gs= DaysBetweenDateAndNow(giYear,1,1)-DaysBetweenDateAndNow(giYear,giMonth,giDay)  //-11
			var li_Days2_Ns
			
			if (li_Days_Gs<li_DaysG2N) {
				niYear=niYear-1
				y_Str=LongLife[giYear-BeginYear-2]
				IsLYear=y_Str.substr(0,2)
				MonType=parseInt(y_Str.substr(2,4),10).toString(2)
				MonType=Format_MonthStr(MonType)
				
				li_DaysG2N=parseInt(y_Str.substr(7,2),10)
				li_Days_Gs= DaysBetweenDateAndNow(niYear,1,1)-DaysBetweenDateAndNow(giYear,giMonth,giDay)
				li_Days2_Ns= li_Days_Gs - li_DaysG2N
			}else{
				li_Days2_Ns= li_Days_Gs - li_DaysG2N
			}
			
			li_Days2_Ns=li_Days2_Ns+1
			
			var mothdays
			var flag_IsLMonth
			
			for (i=0;i<12;i++ ){
				mothdays=(MonType.substr(i,1)==1)?30:29 ;
				
				if (IsLYear=="14") {
					mothdays=(y_Str.substr(6,1)==2)?30:29 ;
					IsLYear=15
					flag_IsLMonth=i
				}
				
				if (li_Days2_Ns>mothdays) {
					li_Days2_Ns=li_Days2_Ns-mothdays;
				}else{
					niMonth=i+1;
				
					if (IsLYear=="15" && flag_IsLMonth==i) niMonth=-niMonth;
					niDay=li_Days2_Ns
				
					break;
				}
				
				if (IsLYear==(i+1)) {
					i=i-1;
					IsLYear="14";
				}
			
			}
			
			var DateArray = new Array(niYear,niMonth,niDay)
			return DateArray
			
		}
		
		
		function N2G(niYear,niMonth,niDay){
		
			var  giYear,giMonth,giDay
			if (niYear<BeginYear || niYear>EndYear) return false;
			giYear=niYear;
			var y_Str=LongLife[giYear-BeginYear-1]
			
			var IsLYear=y_Str.substr(0,2)
			var MonType=parseInt(y_Str.substr(2,4),10).toString(2)
			MonType=Format_MonthStr(MonType)
			
			var li_DaysG2N=parseInt(y_Str.substr(7,2),10)
			
			var mothdays
			var flag_IsLMonth=0
			var li_Days2_Ns=0
			if (niMonth<0) { 
				niMonth=-niMonth 
				flag_IsLMonth=1
			}
			
			for (i=0;i<12;i++ ){
				mothdays=(MonType.substr(i,1)==1)?30:29 ;
				
				if (IsLYear=="14") {
					mothdays=(y_Str.substr(6,1)==2)?30:29 ;
					IsLYear=15
				}
				
				if (IsLYear==15 && flag_IsLMonth==1) {
					li_Days2_Ns=li_Days2_Ns + niDay
					break;
				}
				
				if (i<niMonth-1) {
					li_Days2_Ns=li_Days2_Ns + mothdays;
					
				}else{
					li_Days2_Ns=li_Days2_Ns + niDay
					break;
				}
				
				if (IsLYear!=13 && IsLYear==(i+1)) {
					
					i=i-1;
					IsLYear="14";
				}
				
			
			}
			
			var li_Days_Gs = li_Days2_Ns + li_DaysG2N - 1
			
			var ls_GS2Now= DaysBetweenDateAndNow(giYear, 1, 1)
			
			var ls_G2Now=ls_GS2Now-li_Days_Gs
			
			var returndate= new Date(m_GetDateByDays2Now(ls_G2Now));
			
			
			giYear=returndate.getFullYear()
			giMonth=returndate.getMonth()+1 
			giDay=returndate.getDate()
			
			var DateArray = new Array(giYear,giMonth,giDay)
			return DateArray
			
		}
		
		
		function DaysBetweenDateAndNow(yr, mo, dy){
			var d, r, t1, t2, t3;            // 声明变量。
			var MinMilli = 1000 * 60         // 初始化变量。
			var HrMilli = MinMilli * 60
			var DyMilli = HrMilli * 24
			t1 = Date.UTC(yr, mo - 1, dy)    // 获取从 1/1/1970 开始的毫秒数。
			d = new Date();                  // 创建 Date 对象。
			t2 = d.getTime();                // 获取当前时间。
			if (t2 >= t1) 
				t3 = t2 - t1;
			else
				t3 = t1 - t2;
			r = Math.round(t3 / DyMilli);
			
			if (t2 < t1) r=-r;
			
			return(r);                       // 返回差。
		}

		
		
			//------------begin action class---------------
			function fload()
			{
				fPopCalendar(document.all.txt1, document.all.txt1);
			}

			function fkeydown()
			{
				if(event.keyCode==27){
					event.returnValue = null;
					window.returnValue = null;
					window.close();
				}else{
					var aa = window.event.keyCode
					//alert(aa)
					if (aa!=8 && aa!=46 && (aa<48 || aa>57) && (aa<96 || aa>105) && (aa<35 || aa>40)  ) {
						if (window.event.srcElement.id=="txt_Day2Now" && (aa==189 || aa==109) ) {
							window.event.returnValue=true
						}else{
							window.event.returnValue=false
						}
						
					}
					
				}
			}
			
			function fkeyup(){
				var aa = window.event.keyCode
				if (!(aa>=35 && aa<=40)) {
					if (window.event.srcElement.id=="txt_NYear" || window.event.srcElement.id=="txt_NMonth" || window.event.srcElement.id=="txt_NDay") {
							window.event.returnValue = true;
							FromN2G()
					}
					
					if (window.event.srcElement.id=="txt_Day2Now") {
					
							window.event.returnValue = true;
							Day2Now_Change()
							
					}
				}
			}
			
			function d_onselect(){
					//alert(window.event.srcElement.id)
					//if (window.event.srcElement.id=="txt_NYear" || window.event.srcElement.id=="txt_NMonth" || window.event.srcElement.id=="txt_NDay" || window.event.srcElement.id=="txt_Day2Now") {
					//	window.document.selection.empty();
			//		alert(window.document.selection.type)
					//}
			}
			
			function setkeyevent(){
				getdocobj("txt_Day2Now").onkeydown=fkeydown;
				getdocobj("txt_Day2Now").onkeyup=fkeyup;
				
				getdocobj("txt_NYear").onkeydown=fkeydown;
				getdocobj("txt_NYear").onkeyup=fkeyup;
				
				getdocobj("txt_NMonth").onkeydown=fkeydown;
				getdocobj("txt_NMonth").onkeyup=fkeyup;
				
				getdocobj("txt_NDay").onkeydown=fkeydown;
				getdocobj("txt_NDay").onkeyup=fkeyup;
				
			}