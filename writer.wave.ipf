// haskell-like wave function

Function length(w)
	WAVE/T w
	Variable len=DimSize(w,0)
	return NumType(len) ? 0 : len
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
