#include "::writer"
#include ":writer_test"

Function test_string()
	
	// writer#partition
	// basic
	eq_texts( writer#partition("test","")    , {"test","",""})
	eq_texts( writer#partition("test","a")   , {"test","",""})
	eq_texts( writer#partition("test","e")   , {"t","e","st"})
	eq_texts( writer#partition("test","(e)") , {"t","e","st"})
	eq_texts( writer#partition("test","(((e)))") , {"t","e","st"})
	eq_texts( writer#partition("test","[a-f]") , {"t","e","st"})
	eq_texts( writer#partition("test","(test|check)") , {"","test",""})
	// anchar
	eq_texts( writer#partition("test","^te") , {"","te","st"})
	eq_texts( writer#partition("test","st$") , {"te","st",""})
	eq_texts( writer#partition("test","^(t)"), {"","t","est"})
	eq_texts( writer#partition("test","(t)$"), {"tes","t",""})
	eq_texts( writer#partition("test","^t$")    , {"test","",""})
	eq_texts( writer#partition("test","^test$") , {"","test",""})
	// reference
	eq_texts( writer#partition("This is a test.","s"), {"Thi","s"," is a test."})
	eq_texts( writer#partition("This is a test.","(?<!Thi)s"), {"This i","s"," a test."})
	eq_texts( writer#partition("This is a test.","(?<=e)s"  ), {"This is a te","s","t."})

	// writer#scan
	eq_texts( writer#scan("","") , $"")
	eq_texts( writer#scan("","\\w") , $"")
	eq_texts( writer#scan("of the people, by the people, for the people","\\w+") , {"of", "the", "people", "by", "the", "people", "for", "the", "people"})
	eq_texts( writer#scan("of the people, by the people, for the people","people") , {"people","people","people"})
	eq_texts( writer#scan("Hokkaido:Sapporo, Aomori:Aomori, Iwate:Morioka","(\\w+):(\\w+)") , { {"Hokkaido", "Sapporo"},{"Aomori", "Aomori"},{"Iwate", "Morioka"} })
	eq_texts( writer#scan("foobar","..") , {"fo","ob","ar"})
	eq_texts( writer#scan("foobar","o" ) , {"o","o"})
	eq_texts( writer#scan("foobarbazfoobarbaz","ba." ) , {"bar", "baz", "bar", "baz"})
	eq_texts( writer#scan("foobar","(.)" ) , {{"f"},{"o"},{"o"},{"b"},{"a"},{"r"}})
	eq_texts( writer#scan("foobarbazfoobarbaz","(ba)(.)" ) , {{"ba", "r"}, {"ba", "z"}, {"ba", "r"}, {"ba", "z"}})

	// writer#split
	eq_texts( writer#split("","") , {""})
	eq_texts( writer#split("hello,world,Igor",",") , {"hello","world","Igor"})
	eq_texts( writer#split("hello, world  , Igor","\\s*,\\s*") , {"hello","world","Igor"})
	eq_texts( writer#split("hello, world  ; Igor","\\s*(,|;)\\s*") , {"hello",",","world",";","Igor"})
	eq_texts( writer#split("hello","") , {"h","e","l","l","o"})

	eq_texts( writer#split("a,b,c","\\w.") , {"","","c"})
	eq_texts( writer#split("a,b,c","(\\w.)") , {"","a,","","b,","c"})
	eq_texts( writer#split("a,b,c","^(\\w.)") , {"","a,","b,c"})
	
	// writer#sub
	eq_strs( writer#sub("","",""), "" )
	eq_strs( writer#sub("test","\\w","T"), "Test" )
	eq_strs( writer#sub("test","\\w","T"), "Test" )
	eq_strs( writer#sub("hello, world","\\w+","*\\&*"), "*hello*, world" )
	eq_strs( writer#sub("hello, world","\\w+","\\0\\'"), "hello, world, world" )

	// writer#gsub
	eq_strs( writer#gsub("","",""), "" )
	eq_strs( writer#gsub("hello,\\nworld\\r\\n","\\\\n|\\\\r\\\\n","<br />"), "hello,<br />world<br />" )
	eq_strs( writer#gsub("_Igor_ is _cool_.","_(.+?)_","<em>\\1</em>"), "<em>Igor</em> is <em>cool</em>." )
	eq_strs( writer#gsub("a,b,c","(?<=,).","_"), "a,_,_" )
	eq_strs( writer#gsub("a,b,c","(?=,)." ,"_"), "a_b_c" ) // This is a strange result, but compatible with Ruby. 


	eq_strs( writer#gsub("a,b,c","\\w","",proc=WT_sub), "_,_,_" )
	eq_strs( writer#gsub("Hello, World","\\w","",proc=WT_sub), "_____, _____" )
	eq_strs( writer#gsub("Hello, World","\\W","",proc=WT_sub), "Hello__World" )

End

Function/S WT_sub(s)
	String s
	if(strlen(s))
		return "_"+WT_sub(s[1,inf])
	endif
	return ""
End 
