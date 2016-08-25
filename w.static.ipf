#pragma ModuleName=W
// ruby-like string function

// Ruby: s.partition(/expr/)
static Function/WAVE partition(s,expr)
	String s,expr
	expr=IncreaseSubpatternNumber(2,expr)
	String pre,pst
	if(GrepString(expr,"^\\^")) // ^...(...) -> ^()...(...)
		expr="^()("+expr[1,inf]+")"
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

// Ruby: s.scan(/expr/)
static Function/WAVE scan(s,expr)
	String s,expr
	WAVE/T w=SubPatterns( s, "("+IncreaseSubpatternNumber(1,expr)+")")
	Variable num=DimSize(w,0)
	if(num>1 || strlen(expr)==0)
		DeletePoints 0,1,w
	endif
	if(DimSize(w,0)==0 || hasCaret(expr) )
		return w
	else
		WAVE/T part=partition(s,expr)
		if(num>1)
			WAVE/T buf=scan(part[2],expr)
			Variable Nw=DimSize(w,0), Nb=DimSize(buf,0)
			if(Nb>0 && Nb>Nw)
				InsertPoints Nw,Nb-Nw,w 
			elseif(Nb>0)
				InsertPoints Nb,Nw-Nb,buf 			
			endif
			Concatenate/T {buf},w
		else
			Concatenate/T/NP {scan(part[2],expr)},w
		endif
		return w
	endif
End

// Ruby: s.split(/expr/)
static Function/WAVE split(s,expr)
	String s,expr
	if(empty(expr) && strlen(s))
		Make/FREE/T/N=(strlen(s)) w=s[p]; return w
	endif
	WAVE/T w = partition(s,expr)
	if(empty(w[1]))
		Make/FREE/T w={s}; return w
	endif
	Make/FREE/T buf={w[0]}
	if(hasCaret(expr))
		Concatenate/NP/T {SubPatterns(s,expr)},buf
		InsertPoints DimSize(buf,0),1,buf; buf[inf]=w[2]	
	else
		Concatenate/NP/T {SubPatterns(s,expr) ,split(w[2],expr) },buf
	endif
	return buf
End

// Ruby: s.sub(/expr/,"alt")
static Function/S sub(s,expr,alt)
	String s,expr,alt
	WAVE/T w=partition(s,expr)
	if(empty(w[1]))
		return s
	endif
	WAVE/T a=split(alt,"(\\\\\\d|\\\\&|\\\\`|\\\\'|\\\\+)")
	Variable i,N=DimSize(a,0); alt=""
	for(i=0;i<N;i+=1)
		if(GrepString(a[i],"\\\\0|\\\\&"))
			alt+=w[1]
		elseif(GrepString(a[i],"\\\\`"))
			alt+=w[0]
		elseif(GrepString(a[i],"\\\\'"))
			alt+=w[2]
		elseif(GrepString(a[i],"\\\\\\d"))
			Variable num=Str2Num((a[i])[1])
			WAVE/T sub=SubPatterns(s,expr)
			if(DimSize(sub,0)+1>num)
				alt+=sub[num-1]
			endif
		else
			alt+=a[i]
		endif
	endfor
	return w[0]+alt+w[2]
End

// Ruby: s.gsub(/expr/,"alt")
static Function/S gsub(s,expr,alt)
	String s,expr,alt
	WAVE/T w=partition(s,expr)
	if(empty(w[1]))
		return s
	elseif(hasCaret(expr) || hasDollar(expr))
		return sub(s,expr,alt)
	else
		return sub(w[0]+w[1],expr,alt)+gsub(w[2],expr,alt)	
	endif	
End

static Function empty(s)
	String s
	return !strlen(s)
End
static Function hasCaret(expr)
	String expr
	return GrepString(expr,"^\\(*\\^")
End
static Function hasDollar(expr)
	String expr
	return GrepString(expr,"\\$\\)*$")
End

static Function/S IncreaseSubpatternNumber(n,s)
	Variable n; String s
	String head,body,tail
	SplitString/E="(.*?)(\\(\\?(\\d+\\)))(.*)" s,head,body,body,tail
	if(empty(body))
		return s
	endif
	return head+"(?"+Num2Str(Str2Num(body)+n)+")"+IncreaseSubpatternNumber(n,tail)
End

static Function/WAVE SubPatterns(s,expr)
	String s,expr
	DFREF here=GetDataFolderDFR(); SetDataFolder NewFreeDataFolder()
	String s_   =ReplaceString("\"",ReplaceString("\\",s   ,"\\\\"),"\\\"")
	String expr_=ReplaceString("\"",ReplaceString("\\",expr,"\\\\"),"\\\"")
	String cmd; sprintf cmd,"SplitString/E=\"%s\" \"%s\"", expr_, s_
	SplitString/E=expr s
	Make/FREE/T/N=(V_Flag) w; Variable i, N=V_Flag
	for(i=0;i<N;i+=1)
		Execute/Z "String/G s"+Num2Str(i)
		sprintf cmd,"%s,s%d",cmd,i
	endfor
	Execute/Z cmd
	for(i=0;i<N;i+=1)
		SVAR sv=$"s"+Num2Str(i)
		w[i]=sv
	endfor
	SetDataFolder here
	return w
End
// haskell-like wave function

// Prototype Functions
override Function/WAVE Writer_ProtoTypeReturn(s)
	String s
	Make/FREE/T w={s}; return w
End
override Function/S Writer_ProtoTypeId(s)
	String s
	return s
End

// Basic
static Function length(w)
	WAVE/T w
	Variable len=DimSize(w,0)
	return NumType(len) ? 0 : len
End
static Function null(w)
	WAVE/T w
	return !length(w)
End

static Function/S head(w)
	WAVE/T w
	if(null(w))
		return ""
	endif
	return w[0]
End
static Function/WAVE tail(w)
	WAVE/T w
	if(null(w))
		return void()
	endif
	Duplicate/FREE/T w,ww
	DeletePoints 0,1,ww
	return ww
End

static Function/WAVE void()
	Make/FREE/T/N=0 w; return w
End

// Construction
static Function/WAVE cons(s,w)
	String s; WAVE/T w
	if(null(w))
		return return(s)
	endif
	Duplicate/FREE/T w,ww; InsertPoints 0,1,ww; ww[0]=s; return ww
End
static Function/WAVE concat(w1,w2)
	WAVE/T w1,w2
	if(null(w1) && null(w2))
		return void()
	elseif(null(w1))
		return cons(head(w2),tail(w2))
	endif
	return cons(head(w1),concat(tail(w1),w2))
End

// Transformation
static Function/WAVE map(f,w)
	FUNCREF Writer_ProtoTypeId f; WAVE/T w
	if(null(w))
		return void()
	endif
	return cons(f(head(w)),map(f,tail(w)))
End

// Lifting
static Function/WAVE bind(w,f)
	WAVE/T w; FUNCREF Writer_ProtoTypeReturn f
	if(null(w))
		return void()
	endif
	return concat(f(head(w)),bind(tail(w),f))
End
static Function/WAVE return(s)
	String s
	Make/FREE/T w={s}; return w
End
