// ruby-like string functions

Function/WAVE partition(s,expr)
	String s,expr
	expr=IncreaseSubpatternNumber(2,expr)
	String pre,pst
	if(GrepString(expr,"^\\^")) // ^...(...) -> ^(...)(...)
		SplitString/E="^\\^((\\\\\\\\|\\\\\\(|[^\\(\\\\]|\\\\[^\\(])*)(.*)" expr,pre,pst,pst
		if(strlen(pre)==0)
			expr = "^()("+pst+")"
		elseif(strlen(pst)==0)
			expr = "^()("+pre+")"		
		else
			expr = "^("+pre+")("+pst+")"
		endif
	elseif(GrepString(expr,"^\\(+\\^")) // ((^...)) -> ^(.*)((...))
		SplitString/E="^(\\(+)\\^(.*)" expr,pre,pst
		expr = "^(.*?)"+"("+pre+pst+")"
	else
		expr = "(.*?)("+expr+")"
	endif
	String head,body,tail
	SplitString/E=expr s,head,body
	tail=s[strlen(head+body),inf]
	if(!strlen(body))
		Make/FREE/T w={s,"",""}
	else
		Make/FREE/T w={head,body,tail}
	endif
	return w
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

