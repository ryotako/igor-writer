

Function eq_texts(w1,w2)
	WAVE/T w1,w2
	return eq_texts_(w1,w2)
End

Function eq_text_with_list(w1,list)
	WAVE/T w1; String list
	Make/FREE/T/N=(ItemsInList(list)) w2=StringFromList(p,list)
	eq_texts_(w1,w2)
End

Function eq_strs(s1,s2)
	String s1,s2
	return eq_texts_({s1},{s2})
End

static Function eq_texts_(w1,w2)
	WAVE/T w1,w2
	if(null(w1) && null(w2))
		return pass()
	elseif(!WaveExists(w1) && !WaveExists(w2))
		return fail()
	elseif(!DimEq(w1,w2,0) || !DimEq(w1,w2,1) || !DimEq(w1,w2,2) || !DimEq(w1,w2,3) )
		return fail()
	else
		Make/FREE/N=(DimSize(w1,0),DimSize(w1,1),DimSize(w1,2),DimSize(w1,3)) w=cmpstr(w1,w2,1)
		return WaveMax(w)==0 ? pass() : fail()
	endif
End
static Function DimEq(w1,w2,dim)
	WAVE/T w1,w2; Variable dim
	return DimSize(w1,dim) == DimSize(w2,dim)
End


static Function pass()
End

static Function fail()
	String all_info = GetRTStackInfo(3)
	String info = StringFromList(ItemsInList(all_info)-4,all_info)
	String fun  = StringFromList(0,info,",")
	String win  = StringFromList(1,info,",")
	String line = StringFromList(2,info,",")
	String msg,jmp
	if(strlen(fun))
		sprintf msg,">> \"%s\" failed in line %s, procedure \"%s\"",fun,line,win
		win = win+SelectString(strlen(WinList(win,";","WIN:128")),".ipf","")		
		msg += " >> "+TargetLineStr(win,Str2Num(line))
		sprintf jmp,"\tDisplayProcedure/W=$\"%s\"/L=%s",win,line
	else
		sprintf msg,">> failed in unknowon location"; jmp=""
	endif
	print msg
	print jmp
End

static Function/S TargetLineStr(win,line)
	String win; Variable line
	String buf
	SplitString/E="^\\t*(.*)" StringFromList(line,ProcedureText("",line,win),"\r"), buf
	return buf
End

static Function null(w)
	WAVE/T w
	return !WaveExists(w) || numpnts(w)==0
End

