# igor-writer
Library to manipulate text waves

### writer.string
Ruby-like functions for regular expression 
 - sub(String s, String expr, String alt)
 - gsub(String s, String expr, String alt)
 - split(String s, String expr)
 - scan(String s, String expr)
 - partition(String s, String expr)

### writer.wave
Haskell-like functions for text waves
 - length(Wave/T w), null(Wave/T w)
 - head(Wave/T w), tail(Wave/T w)
 - void()
 - cons(String s, Wave/T w), concat(Wave/T w1, Wave/T w2)
 - map(FuncRef id f, Wave/T w)
 - bind(Wave/T w, FuncRef return f), return(String s) 

 
