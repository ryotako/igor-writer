//------------------------------------------------------------------------------
// This procedure file is packaged by igmodule
// Fri,09 Dec 2016
//------------------------------------------------------------------------------
#pragma ModuleName=writer

//------------------------------------------------------------------------------
// original file: writer_main.ipf 
//------------------------------------------------------------------------------
#if !ItemsInList(WinList("writer_main.ipf",";",""))

//#include ":writer_string"
//#include ":writer_list"

#endif

//------------------------------------------------------------------------------
// original file: writer_string.ipf 
//------------------------------------------------------------------------------
#if !ItemsInList(WinList("writer_string.ipf",";",""))

// ruby-like string function
//#pragma ModuleName=wString

override Function/S Writer_ProtoTypeSub(s)
	String s
	return s
End


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
//    or s.sub(/expr/){proc}
static Function/S sub(s,expr,alt [proc])
	String s,expr,alt; FUNCREF Writer_ProtoTypeSub proc
	WAVE/T w=partition(s,expr)
	if(empty(w[1]))
		return s
	endif
	if(!ParamIsDefault(proc))
		return w[0]+proc(w[1])+w[2]
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
static Function/S gsub(s,expr,alt [proc])
	String s,expr,alt; FUNCREF Writer_ProtoTypeSub proc
	WAVE/T w=partition(s,expr)
	if(empty(w[1]))
		return s
	elseif(hasCaret(expr) || hasDollar(expr))
		if(ParamIsDefault(proc))
			return sub(s,expr,alt)
		else
			return sub(s,expr,alt,proc=proc)		
		endif
	else
		if(ParamIsDefault(proc))
			return sub(w[0]+w[1],expr,alt)+gsub(w[2],expr,alt)		
		else
			return sub(w[0]+w[1],expr,alt,proc=proc)+gsub(w[2],expr,alt,proc=proc)
		endif
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
	String cmd="SplitString/E=\""+expr_+ "\" \""+s_+"\""
	SplitString/E=expr s
	Make/FREE/T/N=(V_Flag) w; Variable i, N=V_Flag
	for(i=0;i<N;i+=1)
		Execute/Z "String/G s"+Num2Str(i)
		cmd+=",s"+Num2Str(i)
	endfor
	Execute/Z cmd
	for(i=0;i<N;i+=1)
		SVAR sv=$"s"+Num2Str(i)
		w[i]=sv
	endfor
	SetDataFolder here
	return w
End

#endif

//------------------------------------------------------------------------------
// original file: writer_list.ipf 
//------------------------------------------------------------------------------
#if !ItemsInList(WinList("writer_list.ipf",";",""))

// haskell-like wave function
//#pragma ModuleName=wList

// Prototype Functions
override Function/S Writer_ProtoTypeId(s)
	String s
	return s
End
override Function/S Writer_ProtoTypeAdd(s1,s2)
	String s1,s2
	return s1+s2
End
override Function/WAVE Writer_ProtoTypeSplit(s)
	String s
	Make/FREE/T/N=(ItemsInList(s)) w=StringFromList(p,s); return w
End
override Function Writer_ProtoTypeLength(s)
	String s
	return strlen(s)
End

// cast a textwave into a 1D textwave
static Function/WAVE cast(w)
	WAVE/T w
	if(WaveExists(w))
		Make/FREE/T/N=(DimSize(w,0)) f=w
	else
		Make/FREE/T/N=0 f
	endif
	return f
End

////////////////////////////////////////
// Basic ///////////////////////////////
////////////////////////////////////////
static Function/WAVE cons(s,w) // (:)
	String s; WAVE/T w
	if(null(w))
		return cast({s})
	endif
	Duplicate/FREE/T cast(w),f
	InsertPoints 0,1,f
	f[0]=s
	return f
End
static Function/WAVE extend(w1,w2) // (++)
	WAVE/T w1,w2
	Make/FREE/T/N=0 f
	Concatenate/NP/T {cast(w1),cast(w2)},f
	return f
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
		return cast($"")
	endif
	WAVE/T f=cast(w)
	DeletePoints 0,1,f
	return f
End

static Function/S last(w)
	WAVE/T w
	if(null(w))
		return ""
	endif
	return w[inf]
End
static Function/WAVE init(w)
	WAVE/T w
	if(null(w))
		return cast($"")
	endif
	WAVE/T f=cast(w)
	DeletePoints length(f)-1,1,f
	return f	
End

static Function length(w)
	WAVE/T w
	return numpnts(cast(w))
End
static Function null(w)
	WAVE/T w
	return !length(w)
End

////////////////////////////////////////
// Construction ////////////////////////
////////////////////////////////////////

static Function/WAVE map(f,w)
	FUNCREF Writer_ProtoTypeId f; WAVE/T w
	WAVE/T buf=cast(w)
	if(length(buf))
		buf=f(w)
	endif
	return buf
End

static Function/S foldl(f,s,w)
	FUNCREF Writer_ProtoTypeAdd f; String s; WAVE/T w
	if(null(w))
		return s
	endif
	return foldl(f, f(s,head(w)), tail(w)) 
End
static Function/S foldl1(f,w)
	FUNCREF Writer_ProtoTypeAdd f; WAVE/T w
	return foldl(f,head(w),tail(w))
End

static Function/S foldr(f,s,w)
	FUNCREF Writer_ProtoTypeAdd f; String s; WAVE/T w
	if(null(w))
		return s
	endif
	return foldr(f, f(last(w),s), init(w)) 
End
static Function/S foldr1(f,w)
	FUNCREF Writer_ProtoTypeAdd f; WAVE/T w
	return foldl(f,last(w),init(w))
End

static Function/WAVE concatMap(f,w)
	FUNCREF Writer_ProtoTypeSplit f; WAVE/T w
	Make/FREE/T/N=0 buf
	Variable i,N = DimSize(w, 0)
	for(i = 0; i < N; i += 1)
			Concatenate/T/NP {f(w[i])}, buf
	endfor
	return buf
End

static Function any(f,w)
	FUNCREF Writer_ProtoTypeLength f; WAVE/T w
	if(null(w))
		return 0
	endif
	return f(head(w)) || any(f,tail(w))
End
static Function all(f,w)
	FUNCREF Writer_ProtoTypeLength f; WAVE/T w
	if(null(w))
		return 1
	endif
	return f(head(w)) && all(f,tail(w))
End

static Function/WAVE take(n,w)
	Variable n; WAVE/T w
	if(null(w) || n<1 || n!=n)
		return cast($"")
	endif
	return cons(head(w),take(n-1,tail(w)))
End
static Function/WAVE drop(n,w)
	Variable n; WAVE/T w
	if(null(w) || n<1 || n!=n)
		return cast(w)
	endif
	return drop(n-1,tail(w))
End

#endif

