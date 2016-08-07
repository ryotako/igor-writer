// ruby-like string function

Function/WAVE partition(s,expr)
	String s,expr
	if(!GrepString(s,expr))
		Make/FREE/T w={s,"",""}; return w
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
	SplitString/E=expr s,head,body
	tail=s[strlen(head+body),inf]
	Make/FREE/T w={head,body,tail}; return f
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
