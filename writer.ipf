// Library to manipulate text waves

// Basic Functions
Function length(w)
	WAVE/T w
	return DimSize(w,0) > 0
End
Function null(w)
	WAVE/T w
	return !length(w)
End

Function/S head(w)
	WAVE/T w
	if(null(w))
		return ""
	endif
	return w[0]
End
Function/WAVE tail(w)
	WAVE/T w
	if(null(w))
		return void()
	endif
	Duplicate/FREE/T w,ww
	DeletePoints 0,1,ww
	return ww
End

Function/WAVE void()
	Make/FREE/T/N=0 w; return w
End

// Construction
Function/WAVE cons(s,w)
	String s; WAVE/T w
	if(null(w))
		return return(s)
	endif
	Duplicate/FREE/T w,ww; InsertPoints 0,1,ww; ww[0]=s; return ww
End
Function/WAVE concat(w1,w2)
	WAVE/T w1,w2
	if(null(w1) && null(w2))
		return void()
	elseif(null(w1))
		return cons(head(w2),tail(w2))
	endif
	return cons(head(w1),concat(tail(w1),w2))
End

// Transformation
Function/S id(s)
	String s
	return s
End
Function/WAVE map(f,w)
	FUNCREF id f; WAVE/T w
	if(null(w))
		return void()
	endif
	return cons(f(head(w)),map(f,tail(w)))
End

// Lifting
Function/WAVE bind(w,f)
	WAVE/T w; FUNCREF return f
	if(null(w))
		return void()
	endif
	return concat(f(head(w)),bind(tail(w),f))
End
Function/WAVE return(s)
	String s
	Make/FREE/T w={s}; return w
End

// Functions for Strings
Function/WAVE partition(s,expr)
	String s,expr
	if(!GrepString(s,expr))
		return cons(s,cons("",cons("",void())))
	endif
	expr=IncreaseSubpatternNumber(2,expr)
	String pre,pst
	if(GrepString(expr,"^\\^")) // ^...(...) -> ^(...)(...)
		SplitString/E=trim("^\\^ (\\\\|\\(|[^\\(\\]|\\[^\\(])* (\\(.*)") expr,pre,pst
		if(strlen(pre))
			expr = "^("+pre+")("+pst+")"
		else
			expr = "^()("+pst+")"
		endif
	elseif(GrepString(expr,"^\\(+\\^")) // ((^...)) -> ^(.*)((...))
		SplitString/E=trim("^ (\\(+) \\^ (.*)") expr,pre,pst
		expr = "^(.*?)"+"("+pre+pst+")"
	else
		expr = "(.*?)("+expr+")"
	endif
	String head,body,tail
	print s,">>",expr
	SplitString/E=expr s,head,body
	tail=s[strlen(head+body),inf]
	return cons(head,cons(body,cons(tail,void())))
End
static Function/S IncreaseSubpatternNumber(n,s)
	Variable n; String s
	String head,body,tail
	SplitString/E="(.*?)(\\(\\?(\\d+\\)))(.*)" s,head,body,body,tail
	if(strlen(body)<1)
		return s
	endif
	return head+"(?"+Num2Str(Str2Num(body)+n)+")"+IncreaseSubpatternNumber(n,tail)
End

Function/S trim(s)
	String s
	return ReplaceString(" ",s,"")
End