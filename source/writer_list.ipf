// haskell-like wave function
#pragma ModuleName=wList

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
	buf=f(w)
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
			Concatenate/T {f(w[i])}, buf
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
