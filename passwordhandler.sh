#!/bin/bash
# handles fetching of passwords, extracting, writing to file, and returning current, daily password

DEST="https://wifipassword.aau.dk/oneday"
PASSWORD_HTML_FILE="oneday.html"
PASSWORD_FILE="passwords.txt"
DATE=$(date +%d/%m/%Y)

extract_password_table() {
    xmllint --html --xpath "//table/tr/*" $1 | perl -pe "s/<th>//g" | perl -pe "s/<\/th>//g" | perl -pe "s/<td>//g" | perl -pe "s/<\/td>//g"
}

update_passwords() {
    source credentials.txt
    printf '%s\n' "Sourced credentials with username: $USERNAME"
    source cas-get.sh $DEST $USERNAME $PASSWORD > $PASSWORD_HTML_FILE
    extract_password_table $PASSWORD_HTML_FILE > $PASSWORD_FILE
    printf '%s\n' "Fetched and extracted updated passwords to $PASSWORD_FILE"
}

get_daily_password() {
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
