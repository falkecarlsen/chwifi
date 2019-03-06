#!/bin/bash
# handles fetching of passwords, extracting, writing to file, and returning current, daily password

# source config for user-variables
source config

# set current date locally
date=$(date +%d/%m/%Y)

extract_password_table() {
    xmllint --html --xpath "//table/tr/*" $1 | perl -pe "s/<th>//g" | perl -pe "s/<\/th>//g" | perl -pe "s/<td>//g" | perl -pe "s/<\/td>//g"
}

update_passwords() {
    printf '%s\n' "Sourced credentials with username: $username"
    source cas-get.sh $dest $username $password > $password_html_file
    extract_password_table $password_html_file > $password_file
    printf '%s\n' "Fetched and extracted updated passwords to '$password_file'"
}

get_daily_password() {
    # if file does not exist, then return error
    if [[ ! -f $password_file ]]; then
        return 1
    fi
    readarray -t password_array < $password_file
    for i in {0..9}
    do 
        # if password found, echo it, and return
        if [[ ${password_array[$i]} =~ $date ]]; then
            echo ${password_array[$i-1]}
            return 0 
        fi
    done
    # else return error
    return 1 
}
