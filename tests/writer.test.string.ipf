#include "::writer.string"
#include ":writer.test"

Function test_string()
	
	// partition
	// basic
	eq_texts( partition("test","")    , {"test","",""})
	eq_texts( partition("test","a")   , {"test","",""})
	eq_texts( partition("test","e")   , {"t","e","st"})
	eq_texts( partition("test","(e)") , {"t","e","st"})
	eq_texts( partition("test","(((e)))") , {"t","e","st"})
	eq_texts( partition("test","[a-f]") , {"t","e","st"})
	eq_texts( partition("test","(test|check)") , {"","test",""})
	// anchar
	eq_texts( partition("test","^te") , {"","te","st"})
	eq_texts( partition("test","st$") , {"te","st",""})
	eq_texts( partition("test","^(t)"), {"","t","est"})
	eq_texts( partition("test","(t)$"), {"tes","t",""})
	eq_texts( partition("test","^t$")    , {"test","",""})
	eq_texts( partition("test","^test$") , {"","test",""})
	// reference
	eq_texts( partition("This is a test.","s"), {"Thi","s"," is a test."})
	eq_texts( partition("This is a test.","(?<!Thi)s"), {"This i","s"," a test."})
	eq_texts( partition("This is a test.","(?<=e)s"  ), {"This is a te","s","t."})

	// scan
	eq_texts( scan("","") , $"")
	eq_texts( scan("","\\w") , $"")
	eq_texts( scan("of the people, by the people, for the people","\\w+") , {"of", "the", "people", "by", "the", "people", "for", "the", "people"})
	eq_texts( scan("of the people, by the people, for the people","people") , {"people","people","people"})
	eq_texts( scan("Hokkaido:Sapporo, Aomori:Aomori, Iwate:Morioka","(\\w+):(\\w+)") , { {"Hokkaido", "Sapporo"},{"Aomori", "Aomori"},{"Iwate", "Morioka"} })
	eq_texts( scan("foobar","..") , {"fo","ob","ar"})
	eq_texts( scan("foobar","o" ) , {"o","o"})
	eq_texts( scan("foobarbazfoobarbaz","ba." ) , {"bar", "baz", "bar", "baz"})
	eq_texts( scan("foobar","(.)" ) , {{"f"},{"o"},{"o"},{"b"},{"a"},{"r"}})
	eq_texts( scan("foobarbazfoobarbaz","(ba)(.)" ) , {{"ba", "r"}, {"ba", "z"}, {"ba", "r"}, {"ba", "z"}})

	// split
	eq_texts( split("","") , {""})
	eq_texts( split("hello,world,Igor",",") , {"hello","world","Igor"})
	eq_texts( split("hello, world  , Igor","\\s*,\\s*") , {"hello","world","Igor"})
	eq_texts( split("hello, world  ; Igor","\\s*(,|;)\\s*") , {"hello",",","world",";","Igor"})
	eq_texts( split("hello","") , {"h","e","l","l","o"})

	eq_texts( split("a,b,c","\\w.") , {"","","c"})
	eq_texts( split("a,b,c","(\\w.)") , {"","a,","","b,","c"})
	eq_texts( split("a,b,c","^(\\w.)") , {"","a,","b,c"})
	
	
End