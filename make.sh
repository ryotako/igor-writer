#!/bin/bash
cd $(dirname $0)

echo '#pragma ModuleName=Writer' > ./writer.ipf
echo '#pragma ModuleName=Wr'     > ./writer.wr.ipf
echo '#pragma ModuleName=W'      > ./writer.w.ipf

sources=source/*.ipf
find . -maxdepth 1 -name '*.ipf' -exec echo "cat $sources >> {}" \; | sh -

# use gnu sed
if [ -x "$(which gsed)" ]; then
  gsed -i 's/^Function/static Function/' ./*.ipf 
else
  sed -i 's/^Function/static Function/' ./*.ipf 
fi 
