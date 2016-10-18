#pragma ModuleName=TestWriterString
#include "unit-testing"
#include "::writer"

static Function test_partition()
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","")    , {"test","",""})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","a")   , {"test","",""})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","e")   , {"t","e","st"})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","(e)") , {"t","e","st"})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","(((e)))") , {"t","e","st"})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","[a-f]") , {"t","e","st"})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","(test|check)") , {"","test",""})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","^te") , {"","te","st"})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","st$") , {"te","st",""})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","^(t)"), {"","t","est"})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","(t)$"), {"tes","t",""})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","^t$")    , {"test","",""})
	CHECK_EQUAL_TEXTWAVES( writer#partition("test","^test$") , {"","test",""})
	CHECK_EQUAL_TEXTWAVES( writer#partition("This is a test.","s"), {"Thi","s"," is a test."})
	CHECK_EQUAL_TEXTWAVES( writer#partition("This is a test.","(?<!Thi)s"), {"This i","s"," a test."})
	CHECK_EQUAL_TEXTWAVES( writer#partition("This is a test.","(?<=e)s"  ), {"This is a te","s","t."})
End

static Function test_scan()
	Make/FREE/T/N=0 NULL
	CHECK_EQUAL_TEXTWAVES( writer#scan("","") , NULL)
	CHECK_EQUAL_TEXTWAVES( writer#scan("","\\w") , NULL)
	CHECK_EQUAL_TEXTWAVES( writer#scan("of the people, by the people, for the people","\\w+") , {"of", "the", "people", "by", "the", "people", "for", "the", "people"})
	CHECK_EQUAL_TEXTWAVES( writer#scan("of the people, by the people, for the people","people") , {"people","people","people"})
	CHECK_EQUAL_TEXTWAVES( writer#scan("Hokkaido:Sapporo, Aomori:Aomori, Iwate:Morioka","(\\w+):(\\w+)") , { {"Hokkaido", "Sapporo"},{"Aomori", "Aomori"},{"Iwate", "Morioka"} })
	CHECK_EQUAL_TEXTWAVES( writer#scan("foobar","..") , {"fo","ob","ar"})
	CHECK_EQUAL_TEXTWAVES( writer#scan("foobar","o" ) , {"o","o"})
	CHECK_EQUAL_TEXTWAVES( writer#scan("foobarbazfoobarbaz","ba." ) , {"bar", "baz", "bar", "baz"})
	CHECK_EQUAL_TEXTWAVES( writer#scan("foobar","(.)" ) , {{"f"},{"o"},{"o"},{"b"},{"a"},{"r"}})
	CHECK_EQUAL_TEXTWAVES( writer#scan("foobarbazfoobarbaz","(ba)(.)" ) , {{"ba", "r"}, {"ba", "z"}, {"ba", "r"}, {"ba", "z"}})
End

static Function test_split()
	CHECK_EQUAL_TEXTWAVES( writer#split("","") , {""})
	CHECK_EQUAL_TEXTWAVES( writer#split("hello,world,Igor",",") , {"hello","world","Igor"})
	CHECK_EQUAL_TEXTWAVES( writer#split("hello, world  , Igor","\\s*,\\s*") , {"hello","world","Igor"})
	CHECK_EQUAL_TEXTWAVES( writer#split("hello, world  ; Igor","\\s*(,|;)\\s*") , {"hello",",","world",";","Igor"})
	CHECK_EQUAL_TEXTWAVES( writer#split("hello","") , {"h","e","l","l","o"})

	CHECK_EQUAL_TEXTWAVES( writer#split("a,b,c","\\w.") , {"","","c"})
	CHECK_EQUAL_TEXTWAVES( writer#split("a,b,c","(\\w.)") , {"","a,","","b,","c"})
	CHECK_EQUAL_TEXTWAVES( writer#split("a,b,c","^(\\w.)") , {"","a,","b,c"})
End

static Function test_sub()
	CHECK_EQUAL_TEXTWAVES( {writer#sub("","","")}, {""} )
	CHECK_EQUAL_TEXTWAVES( {writer#sub("test","\\w","T")}, {"Test"} )
	CHECK_EQUAL_TEXTWAVES( {writer#sub("test","\\w","T")}, {"Test"} )
	CHECK_EQUAL_TEXTWAVES( {writer#sub("hello, world","\\w+","*\\&*")}, {"*hello*, world"} )
	CHECK_EQUAL_TEXTWAVES( {writer#sub("hello, world","\\w+","\\0\\'")}, {"hello, world, world"} )
End

static Function test_gsub()
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("","","")}, {""} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("hello,\\nworld\\r\\n","\\\\n|\\\\r\\\\n","<br />")}, {"hello,<br />world<br />"} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("_Igor_ is _cool_.","_(.+?)_","<em>\\1</em>")}, {"<em>Igor</em> is <em>cool</em>."} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("a,b,c","(?<=,).","_")}, {"a,_,_"} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("a,b,c","(?=,)." ,"_")}, {"a_b_c"} ) // This is a strange result, but compatible with Ruby. 

	CHECK_EQUAL_TEXTWAVES( {writer#gsub("","","")}, {""} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("hello,\\nworld\\r\\n","\\\\n|\\\\r\\\\n","<br />")}, {"hello,<br />world<br />"} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("_Igor_ is _cool_.","_(.+?)_","<em>\\1</em>")}, {"<em>Igor</em> is <em>cool</em>."} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("a,b,c","(?<=,).","_")}, {"a,_,_"} )
	CHECK_EQUAL_TEXTWAVES( {writer#gsub("a,b,c","(?=,)." ,"_")}, {"a_b_c"} ) // This is a strange result, but compatible with Ruby. 
End