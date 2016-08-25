#!/bin/bash
cd $(dirname $0)

:> ./writer.ipf
echo '#pragma ModuleName=Writer' > ./writer.static.ipf
echo '#pragma ModuleName=W'      > ./w.static.ipf

sources=source/*.ipf
find . -maxdepth 1 -name '*.ipf' -exec echo "cat $sources >> {}" \; | sh -

sed -i 's/^Function/static Function/' ./*.static.ipf 

