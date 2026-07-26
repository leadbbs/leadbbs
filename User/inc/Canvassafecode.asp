<!--#include file="canvas.asp"-->
<%
Sub DisplayCanvasCode

 Dim objCanvas
 Dim PointX,PointY,PointColor
 Dim iTemp
 Dim R,G,B,cc,kk 
 Dim BGColor

 cc=90
 kk=27
 
 BGColor = "FFFFFF"
 
 R = Mid(BGColor,1,2)
 G = Mid(BGColor,3,2)
 B = Mid(BGColor,5,2)
  
 
 
 R = DecHex(R)
 G = DecHex(G)
 B = DecHex(B)
 
 Set objCanvas = New Canvas
 
 objCanvas.GlobalColourTable(0) = RGB(255,255,255) ' White
 objCanvas.GlobalColourTable(1) = RGB(0,0,0) ' Black
 objCanvas.GlobalColourTable(2) = RGB(255,0,0) ' Red
 objCanvas.GlobalColourTable(3) = RGB(0,255,0) ' Green
 objCanvas.GlobalColourTable(4) = RGB(0,0,255) ' Blue
 objCanvas.GlobalColourTable(5) = RGB(128,0,0) 
 objCanvas.GlobalColourTable(6) = RGB(0,128,0) 
 objCanvas.GlobalColourTable(7) = RGB(0,0,128)
 objCanvas.GlobalColourTable(8) = RGB(128,128,0) 
 objCanvas.GlobalColourTable(9) = RGB(0,128,128) 
 objCanvas.GlobalColourTable(10) = RGB(128,0,128)
 objCanvas.GlobalColourTable(11) = RGB(R,G,B)

 objCanvas.BackgroundColourIndex = 11
 
 objCanvas.Resize cc,kk,false 
 

Dim SafeCode
SafeCode = Code_RndNumber(1)
  
 For iTemp = 0 To -1
  Randomize timer
  PointX = Int(Rnd * cc)
  PointY = Int(Rnd * kk)
  PointColor = Int(Rnd * 3)+2
  objCanvas.ForegroundColourIndex = PointColor  
  objCanvas.Line PointX,PointY,PointX,PointY 
  
  next
 '边框
 objCanvas.ForegroundColourIndex = 1
 'objCanvas.Line 1,1,cc,1
 'objCanvas.Line 1,kk,1,1
 'objCanvas.Line 1,kk,cc,kk
 'objCanvas.Line cc,1,cc,kk
 objCanvas.Line fix(rnd*cc/3)+1,fix(rnd*kk),fix(cc/2+(rnd*cc/2)+1),fix(rnd*kk)
 objCanvas.Line fix(rnd*cc/3)+1,fix(rnd*kk),fix(cc/2+(rnd*cc/2)+1),fix(rnd*kk)

 dim sc,sk
 '文字
 Randomize timer
 sc = cint(3*Rnd)
 sk = cint(5*Rnd)-cint(2*rnd)
 'DrawTextWE函数作了优化和改进 最后一参数为字符间隔像素 取消空格
 objCanvas.DrawTextWE sc,sk,SafeCode,fix(rnd*4)+6
 'objCanvas.DrawTextNS sc,sk,SafeCode
 
 objCanvas.Write

End Sub  

Function DecHex (HStr)
 
 Dim Result
 Dim i,L
 
 Result = 0
 
 
 L = Len(Hstr)
 

 For i = L-1 To 0 Step -1
 
  Result = Result + (16 ^ i)*GetDecBit(Mid(HStr,i+1,1))
  
 Next
 
 ' README §41: `16 ^ i` is a Double, so Result is a Double — and AxonASP's RGB() returns 0
 ' when any argument is one, which made the captcha's background colour black instead of
 ' white and hid the digits drawn on it. Hand back a Long.
 DecHex = CLng(Result)
 
End Function

Function GetDecBit (HStr)
 
 Dim Result
 Dim R(16)
 Dim i
 
 Result = 0
 
 R(0) = "0"
 R(1) = "1"
 R(2) = "2"
 R(3) = "3"
 R(4) = "4"
 R(5) = "5"
 R(6) = "6"
 R(7) = "7"
 R(8) = "8"
 R(9) = "9"
 R(10) = "A"
 R(11) = "B"
 R(12) = "C"
 R(13) = "D"
 R(14) = "E"
 R(15) = "F"
 
 For i = 0 To 15
  
  if HStr=R(i) Then Result = i : Exit For
  
 Next 
 
 GetDecBit = Result
 
End Function
%>

