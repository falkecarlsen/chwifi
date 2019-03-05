#!/bin/bash
# handles fetching of passwords, extracting, writing to file, and returning current, daily password

DEST="https://wifipassword.aau.dk/oneday"
PASSWORD_HTML_FILE="oneday.html"
PASSWORD_FILE="passwords.txt"
DATE=$(date +%d/%m/%Y)

updatepasswords() {
    source credentials.txt
    printf '%s\n' "Sourced credentials with username: $USERNAME"
    source cas-get.sh $DEST $USERNAME $PASSWORD > $PASSWORD_HTML_FILE
    source extractpasswd.sh $PASSWORD_HTML_FILE > $PASSWORD_FILE
    printf '%s\n' "Fetched, extracted updated passwords to $PASSWORD_FILE"
}

function getcurrentpassword() {
    # if file does not exist, then return error
    if [[ ! -f $PASSWORD_FILE ]]; then
        return 1
    fi
    readarray -t PASSWORD_ARRAY < $PASSWORD_FILE
    for i in {0..9}
    do 
        # if password found, echo it, and return
        if [[ ${PASSWORD_ARRAY[$i]} =~ $DATE ]]; then
            echo ${PASSWORD_ARRAY[$i-1]}
            return 0 
        fi
    done
    # else return error
    return 1 
}
