#!/bin/bash
# handles fetching of passwords, extracting, and writing to file
DEST="https://wifipassword.aau.dk/oneday"
PASSWORD_HTML_FILE="oneday.html"
source credentials.txt
source cas-get.sh $DEST $USERNAME $PASSWORD > $PASSWORD_HTML_FILE
source extractpasswd.sh $PASSWORD_HTML_FILE
