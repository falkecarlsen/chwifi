#!/bin/bash
# handles fetching of passwords, extracting, writing to file, and returning current, daily password
DEST="https://wifipassword.aau.dk/oneday"
PASSWORD_HTML_FILE="oneday.html"
PASSWORD_FILE="passwords.txt"
DATE=$(date +%d/%m/%Y)

function update() {
    source credentials.txt
    echo Sourced credentials with username: $USERNAME
    source cas-get.sh $DEST $USERNAME $PASSWORD > $PASSWORD_HTML_FILE
    echo Updated local cache of passwords
    source extractpasswd.sh $PASSWORD_HTML_FILE > $PASSWORD_FILE
    echo Extracted passwords to $PASSWORD_FILE
}

function getcurrenctpassword() {
    echo Current date is: $DATE
    readarray -t PASSWORD_ARRAY < passwords.txt
    for i in {0..9}
    do 
        echo i:$i array: ${PASSWORD_ARRAY[$i]}
        if [[ ${PASSWORD_ARRAY[$i]} =~ $DATE ]]; then
            echo Got a match: at i: $i, at i-1: ${PASSWORD_ARRAY[$i-1]}
            builtin echo ${PASSWORD_ARRAY[$i-1]}
        fi
    done
}

# set verbosity and shift params down 
if [[ "-v" == "$1" ]]; then
  VERBOSE=1
  shift
fi
echo () {
  [[ "$VERBOSE" ]] && builtin echo $@
}

