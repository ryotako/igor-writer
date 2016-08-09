

Function eq_texts(w1,w2)
	WAVE/T w1,w2
	return eq_texts_(w1,w2)
End

Function eq_text_with_list(w1,list)
	WAVE/T w1; String list
	Make/FREE/T/N=(ItemsInList(list)) w2=StringFromList(p,list)
	eq_texts_(w1,w2)
End

static Function eq_texts_(w1,w2)
	WAVE/T w1,w2
	if(null(w1) && null(w2))
		return pass()
	elseif(!WaveExists(w1) && !WaveExists(w2))
		return fail()
	elseif(DimSize(w1,0) !=DimSize(w2,0))
		return fail()
	else
		Make/FREE/N=(DimSize(w1,0)) w=cmpstr(w1,w2,1)
		return WaveMax(w)==0 ? pass() : fail()
	endif
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
	sprintf msg,">> \"%s\" failed in line %s, procedure \"%s\"",fun,line,win
	win = win+SelectString(strlen(WinList(win,";","WIN:128")),".ipf","")		
	msg += " >> "+TargetLineStr(win,Str2Num(line))
	sprintf jmp,"\tDisplayProcedure/W=$\"%s\"/L=%s",win,line
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

