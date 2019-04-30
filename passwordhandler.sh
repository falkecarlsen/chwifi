#!/bin/bash
# Handles fetching of passwords, extracting, writing to file, and returning current, daily password

# Source config for user-variables
source config

# Set current date locally
date=$(date +%d/%m/%Y)

extract_password_table() {
    xmllint --html --xpath "//table/tr/*" $1 | perl -pe "s/<th>//g" | perl -pe "s/<\/th>//g" | perl -pe "s/<td>//g" | perl -pe "s/<\/td>//g"
}

update_passwords() {
    printf '%s\n' "Sourced credentials with username: $username"
    # Run cashandler at $dest, with $username and $password, and redirect output to html on filesystem
    source cashandler.sh $dest $username $password > $password_html_file
    # Run extractor on html and redirect resulting table to password-file
    extract_password_table $password_html_file > $password_file
    # Assume that some sensible passwords were extracted and read array into variable
    readarray -t password_array < $password_file
    
    # If first password's date in password-file is the current date, then update succeeded and return success
    if [[ ${password_array[3]} =~ $date ]]; then
	    return 0
    else 
    	return 1
    fi
}

get_daily_password() {
    # If file does not exist, then return error
    if [[ ! -f $password_file ]]; then
        return 1
    fi

    # Read in array
    readarray -t password_array < $password_file
    
    # For rows in flattened table
    for i in {0..9}
    do 
        # If password found, echo it, and return success
        if [[ ${password_array[$i]} =~ $date ]]; then
            echo ${password_array[$i-1]}
            return 0 
        fi
    done
    # Else return error
    return 1 
}
