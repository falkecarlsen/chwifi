#!/bin/bash

xmllint --html --xpath "//table/tr/*" $1 | perl -pe "s/<th>//g" | perl -pe "s/<\/th>//g" | perl -pe "s/<td>//g" | perl -pe "s/<\/td>//g"
