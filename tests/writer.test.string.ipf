#include "::writer.string"
#include ":writer.test"

Function test_string()
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

End